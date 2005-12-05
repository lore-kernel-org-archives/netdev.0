From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [RFC: -mm patch] drivers/net/wireless/hostap/hostap_main.c
	shouldn't #include C files
Date: Sun, 4 Dec 2005 18:14:09 -0800
Message-ID: <20051205021409.GB8953@jm.kir.nu>
References: <20051203122309.GD31395@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com, linux-kernel@vger.kernel.org
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20051203122309.GD31395@stusta.de>
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

On Sat, Dec 03, 2005 at 01:23:09PM +0100, Adrian Bunk wrote:
> This patch contains an attempt to properly build hostap.o without 
> #incude'ing C files.

Looks good. However, I did not test this now since this did not apply to
netdev-2.6 (it does not have hostap_main.c). Did the hostap.c to
hostap_main.c rename go only to -mm? I would prefer to do this kind of
changes in a single place and I thought netdev-2.6 would be that. I'm
not following -mm tree at all and it would be easier to go through
patches if they are against netdev-2.6 upstream branch.

-- 
Jouni Malinen                                            PGP id EFC895FA
