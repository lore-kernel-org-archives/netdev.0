From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/3] bridge: Add vlan filtering
 support for default pvid
Date: Sun, 05 Oct 2014 21:22:04 -0400 (EDT)
Message-ID: <20141005.212204.1337564321623828212.davem@davemloft.net>
References: <1412350158-19061-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, stephen@networkplumber.org, cwang@twopensource.com
To: vyasevich@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1412350158-19061-1-git-send-email-vyasevic@redhat.com>
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

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Fri,  3 Oct 2014 11:29:15 -0400

> This series adds default pvid support to vlan filtering in the bridge.
> VLAN 1 (as recommended by 802.1q spec) is used as default pvid on ports. 
> The the user can over-ride this configuration by configuring their
> own vlan information. 
> The user can additionally change the default value throught the
> sysfs interface (netlink comming shortly).
> The user can turn off default pvid functionality by setting default
> pvid to 0. 
> This series changes the default behavior of the bridge when
> vlan filtering is turned on.  Currently, ports without any vlan
> filtering configured will not recevie any traffic at all.  This patch
> changes the behavior of the above ports to receive only untagged traffic.

Series applied, thanks Vlad.
