From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH 2/3] bridge: Add filtering support for
	default_pvid
Date: Mon, 15 Sep 2014 00:21:30 +0900
Message-ID: <5415B27A.2000508@gmail.com>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
	<1410554691-18467-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Vladislav Yasevich <vyasevic@redhat.com>, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1410554691-18467-3-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

(14/09/13 (土) 5:44), Vladislav Yasevich wrote:
> Currently when vlan filtering is turned on on the bridge, the bridge
> will drop all traffic untill the user configures the filter.  This
> isn't very nice for ports that don't care about vlans and just
> want untagged traffic.
> 
> A concept of a default_pvid was recently introduced.  This patch
> adds filtering support for default_pvid.   Now, ports that don't
> care about vlans and don't define there own filter will belong
> to the VLAN of the default_pvid and continue to receive untagged
> traffic.

If user sets pvid, then vid 1 (default_pvid) will become non-pvid but
still not be filtered, right?
vlan_bitmap of default_pvid shouldn't be cleared on setting pvid?

Thanks,
Toshiaki Makita
