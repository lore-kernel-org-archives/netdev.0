From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 2/2] ucc_geth: Rework the TX logic.
Date: Thu, 26 Mar 2009 21:05:43 +0300
Message-ID: <20090326180543.GA2406@oksana.dev.rtsoft.ru>
References: <1238072077-27044-1-git-send-email-Joakim.Tjernlund@transmode.se>
	<1238072077-27044-2-git-send-email-Joakim.Tjernlund@transmode.se>
	<20090326133918.GA27085@oksana.dev.rtsoft.ru>
	<OF5FC70952.28684E98-ONC1257585.005ADBF9-C1257585.005BDD35@transmode.se>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, leoli@freescale.com, netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <OF5FC70952.28684E98-ONC1257585.005ADBF9-C1257585.005BDD35@transmode.se>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 26, 2009 at 05:43:25PM +0100, Joakim Tjernlund wrote:
[...]
> > bd == ugeth->confBd[txQ]
> > and
> > !in_be32((u32 __iomem *)(bd+4))
> > 
> > Are not equivalent wrt. speed. MMIO accessors should be rather
> > slow comparing to normal memory.
> 
> Yes, I know. I did it this way because I something broke under stress
> when ugeth->confBd[txQ] instead. The ucc_geth_tx() and 
> ucc_geth_start_xmit()
> gets out of sync somehow.

Would be great if you could investigate it more. Maybe there is
a serious bug somewhere, or maybe you're introducing another
(yet hidden) bug...

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
