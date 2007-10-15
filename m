From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2] [POWERPC] ucc_geth: Fix build break introduced by
	commit 09f75cd7bf13720738e6a196cc0107ce9a5bd5a0
Date: Mon, 15 Oct 2007 14:51:48 -0400
Message-ID: <4713B6C4.9090909@pobox.com>
References: <1192455830-1028-1-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, leoli@Freescale.com,
	linuxppc-dev@ozlabs.org
To: Emil Medve <Emilian.Medve@Freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <1192455830-1028-1-git-send-email-Emilian.Medve@Freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Emil Medve wrote:
> drivers/net/ucc_geth.c: In function 'ucc_geth_rx':
> drivers/net/ucc_geth.c:3483: error: 'dev' undeclared (first use in this function)
> drivers/net/ucc_geth.c:3483: error: (Each undeclared identifier is reported only once
> drivers/net/ucc_geth.c:3483: error: for each function it appears in.)
> make[2]: *** [drivers/net/ucc_geth.o] Error 1
> 
> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>
> ---
> 
> Here is a convenient link for the culprit patch: http://git.kernel.org/?p=linux/kernel/git/jgarzik/netdev-2.6.git;a=commit;h=09f75cd7bf13720738e6a196cc0107ce9a5bd5a0
> 
> netdev-2.6> scripts/checkpatch.pl 0001-POWERPC-ucc_geth-Fix-build-break-introduced-by-co.patch 
> Your patch has no obvious style problems and is ready for submission.

applied
