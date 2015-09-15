From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] Net: core: sock.c coding style fixes
Date: Tue, 15 Sep 2015 11:43:49 -0700
Message-ID: <20150915184346.GA7817@Alexeis-MacBook-Pro-2.local>
References: <1442339925-17079-1-git-send-email-cristos@vipserv.org>
 <87mvwnbkzr.fsf@x220.int.ebiederm.org>
 <55F8652D.30809@vipserv.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, davem@davemloft.net,
	edumazet@google.com, netdev@vger.kernel.org
To: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34236 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbbIOSn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 14:43:57 -0400
Received: by padhy16 with SMTP id hy16so183844229pad.1
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 11:43:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55F8652D.30809@vipserv.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 15, 2015 at 08:36:29PM +0200, Krzysztof Majzerowicz-Jaszcz wrote:
> OK, sorry. I'll undo the comments then. Do you have any other suggestions?
> 
> KMJ
> 
> On 15/09/15 20:22, Eric W. Biederman wrote:
> > Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org> writes:
> > 
> >> Fixed most coding style issues reported by checkpatch.pl
> > 
> > Ugh.  At least in the matter of comments I find this patch makes
> > the code uglier.
> > 
> > Replacing:
> > /*
> >  *             Important banner about the code
> >  */
> > 
> > with
> >  /* Important banner about the code */
> > 
> > Does not look as nice and does not convey the same information as
> > clearly.
> > 
> > Remember checkpatch.pl is not the ruler or the rules it is a servant
> > with a bunch of heuristics to point out problems.
> > 
> > Eric
> > 
> >> Signed-off-by: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
> >> ---
> >>  net/core/sock.c | 442 +++++++++++++++++++++++++-------------------------------
> >>  1 file changed, 200 insertions(+), 242 deletions(-)

200 checkpatch changes in one commit?

imo it makes sense to fix coding style only if nearby lines are
affected by meaningful changes.
Just blank rewrites like these are more harmful than useful.
They distort git blame, make backporting harder, etc.
