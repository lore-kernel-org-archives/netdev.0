From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 00/17] hv_netvsc: Eliminate the additional
 head room
Date: Tue, 01 Dec 2015 21:54:10 -0500 (EST)
Message-ID: <20151201.215410.1740396521919421561.davem@davemloft.net>
References: <1449016978-9755-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1449016978-9755-1-git-send-email-kys@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Tue,  1 Dec 2015 16:42:58 -0800

> In an attempt to avoid having to allocate memory on the send path, the netvsc
> driver was requesting additional head room so that both rndis header and the
> netvsc packet (the state that had to persist) could be placed in the skb.
> Since the amount of head room requested was exceeding the default head room
> as set in LL_MAX_HEADER, we were forcing a reallocation of skb.
> 
> With this patch-set, I have reduced the size of the netvsc packet to less
> than 20 bytes and with this reduction we don't need to ask for any additional
> headroom. We place the rndis header in the skb head room and we place the
> netvsc packet in control buffer area in the skb.
> 
> V2:  - Addressed  review comments:
>      - Eliminated more fields from netvsc packet structure.
> 
> V3:  - Fixed a typo in patch: hv_netvsc: Don't ask for additional head room in the skb.

Series applied, thanks.
