From: Olivier Langlois <olivier@trillion01.com>
Subject: Re: [PATCH] rtl8192ce is disabling the irqs for too long
Date: Fri, 31 Jan 2014 00:16:08 -0500
Message-ID: <1391145368.2436.249.camel@Wailaba2>
References: <1391062949-14502-1-git-send-email-olivier@trillion01.com>
	 <52EAB3E6.2060809@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, chaoming_li@realsil.com.cn,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mlang45@derytele.com
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alt-proxy87.mail.unifiedlayer.com ([67.222.57.217]:55031 "HELO
	alt-proxy87.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750897AbaAaFWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 00:22:52 -0500
In-Reply-To: <52EAB3E6.2060809@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-30 at 14:19 -0600, Larry Finger wrote:
> On 01/30/2014 12:22 AM, Olivier Langlois wrote:
> > Signed-off-by: Olivier Langlois <olivier@trillion01.com>
> > ---
> >   drivers/net/wireless/rtlwifi/ps.c           |  2 +-
> >   drivers/net/wireless/rtlwifi/rtl8192ce/hw.c | 18 ++++++++++++++++--
> >   2 files changed, 17 insertions(+), 3 deletions(-)
> 
> Olivier,
> 
> I like the fact that you have proposed a solution that has minimal effect on the 
> other PCI drivers under rtlwifi. That certainly decreases the amount of testing 
> needed. Of course, all of them may need the same kind of fix.

This has been done on purpose. I knew that you would appreciate. The
problem is probably present with the other cards but since I could not
validate or test the patch with them, I have left them unchanged. If you
were to determine that it apply to all of them then maybe the patch
could be moved to ps.c to wrap hw_init() call.

> 
> The changes are certainly minimal; however, I do need to test them before giving 
> my Ack.
> 
> As the problem(s) fixed by this patch will affect stable kernels, you should add 
> a "Cc: Stable <stable@vger.kernel.org>" patch.
> 
> Originally, I was going to have you add a comment to the commit message on why 
> you were changing the return value in rtl_ps_enable_nic(), but now I am thinking 
> that this should be a separate commit as it fixes a totally different bug. Yes 
> it is involved with the callback to hw_init, but the bug is independent.

done. I am about to resend the patch splitted into 2 commits.
> 
> Good work on finding this problem.
> 
my pleasure. it has been fun and gratifying.
