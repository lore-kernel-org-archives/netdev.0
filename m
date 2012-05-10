From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 00/13] net: Add and use ether_addr_equal
Date: Thu, 10 May 2012 08:48:48 +0200
Message-ID: <1336632528.4334.1.camel@jlt3.sipsolutions.net>
References: <cover.1336538937.git.joe@perches.com>
	<20120509.212110.437114897180819434.davem@davemloft.net>
	(sfid-20120510_032248_153593_581BC374)
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: coreteam@netfilter.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, netfilter@vger.kernel.org,
	netfilter-devel@vger.kernel.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20120509.212110.437114897180819434.davem@davemloft.net>
	(sfid-20120510_032248_153593_581BC374)
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

On Wed, 2012-05-09 at 21:21 -0400, David Miller wrote:

> That case you didn't convert in mac80211 is probably the
> bug Johannes was talking about which started this whole
> discussion.

The bug case that started it all is in net/wireless/scan.c and Emmanuel
has since changed it back to memcmp(). Not sure if that's the one you
were referring to or not :-)

johannes
