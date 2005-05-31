From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [-mm patch] net/ieee80211/: remove pci.h #include's
Date: Mon, 30 May 2005 18:22:01 -0700
Message-ID: <20050531012200.GC7950@jm.kir.nu>
References: <20050530205634.GQ10441@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, hostap@shmoo.com,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050530205634.GQ10441@stusta.de>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Mon, May 30, 2005 at 10:56:34PM +0200, Adrian Bunk wrote:

> I was wondering why editing pci.h triggered the rebuild of three files 
> under net/, and as far as I can see, there's no reason for these three 
> files to #include pci.h .

>  net/ieee80211/ieee80211_module.c |    1 -
>  net/ieee80211/ieee80211_rx.c     |    1 -
>  net/ieee80211/ieee80211_tx.c     |    1 -

I don't know where these came from since Host AP driver does not include
linux/pci.h into the files doing generic IEEE 802.11 processing. Anyway,
I have nothing against removing these include lines.

-- 
Jouni Malinen                                            PGP id EFC895FA
