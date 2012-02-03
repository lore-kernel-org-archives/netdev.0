From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Fri, 3 Feb 2012 06:38:12 +0000
Message-ID: <1328251092.13189.29.camel@dagon.hellion.org.uk>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	 <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328203710.5553.94.camel@leeds.uk.xensource.com>
	 <1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328212761.28964.77.camel@dagon.hellion.org.uk>
	 <1328214866.2480.18.camel@edumazet-laptop>
	 <1328215821.13189.24.camel@dagon.hellion.org.uk>
	 <CAP=VYLq3CZBjC2ecOdGqAejN5Atu9kd1HovhQwc-eVk-q8ArJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:38526 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab2BCGiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 01:38:14 -0500
In-Reply-To: <CAP=VYLq3CZBjC2ecOdGqAejN5Atu9kd1HovhQwc-eVk-q8ArJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-02 at 22:52 +0000, Paul Gortmaker wrote:
> On Thu, Feb 2, 2012 at 3:50 PM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> > On Thu, 2012-02-02 at 20:34 +0000, Eric Dumazet wrote:
> 
> [...]
> 
> >
> > I don't think it is at all unreasonable to ask for bug fixes but in this
> > case Wei's series is removing the code in question (which would also
> > undoubtedly fix the bug).
> >
> > As it happens the fix turns out to be simple but if it were complex I
> > would perhaps have disagreed more strongly about spending effort fixing
> > code that is removed 2 patches later, although obviously that would have
> > depended on the specifics of the fix in that case.
> 
> Lots of people are relying on git bisect.  If you introduce build failures
> or known bugs into any point in history, you take away from the value
> in git bisect.  Sure, it happens by accident, but it shouldn't ever be
> done knowingly.

Sure. In this case the bug has been there since 2.6.39, it isn't
introduced by this series.

Ian.
