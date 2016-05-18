From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for
 SOCK_DESTROY
Date: Wed, 18 May 2016 11:51:08 -0700
Message-ID: <20160518115108.46fabd49@xeon-e3>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
	<1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
	<CAKD1Yr08Zm55=oxMWUxL5-=D-gt4Hg5nfKSH7KRi38Ki=VyqcQ@mail.gmail.com>
	<bf9bfd17-9b96-dac4-a429-5470a44aa66c@cumulusnetworks.com>
	<CAKD1Yr2tzVATZLYV86KmvPvAohW2-49J+6Wc6PuP+xmLwBz9Qg@mail.gmail.com>
	<39db6a27-9dfa-1c9a-2699-2f01a0e64a66@cumulusnetworks.com>
	<CAKD1Yr3itVp4UgWF1uFSVRKzQm_vaLEQT=FnfBNjUJJVTj2Z+Q@mail.gmail.com>
	<3d0fd83a-fa88-8ceb-a44d-237f5a005eb4@cumulusnetworks.com>
	<CAKD1Yr0E9i0s0ocSyYhEjODnVVQVBPOfbepvORAhT9gi9Qqz6A@mail.gmail.com>
	<a3cafb2342fa6a754fc389947f77f248@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
	David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32850 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbcERSu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 14:50:59 -0400
Received: by mail-pa0-f50.google.com with SMTP id xk12so20479054pac.0
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 11:50:59 -0700 (PDT)
In-Reply-To: <a3cafb2342fa6a754fc389947f77f248@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 May 2016 12:35:53 -0600
subashab@codeaurora.org wrote:

> On 2016-05-16 20:29, Lorenzo Colitti wrote:
> > On Tue, May 17, 2016 at 11:24 AM, David Ahern <dsa@cumulusnetworks.com> 
> > wrote:
> >> As I mentioned we can print the unsupported once or per socket matched 
> >> and
> >> with the socket params. e.g.,
> >> 
> >> +               } else if (errno == EOPNOTSUPP) {
> >> +                       printf("Operation not supported for:\n");
> >> +                       inet_show_sock(h, diag_arg->f, 
> >> diag_arg->protocol);
> >> 
> >> Actively suppressing all error messages is just wrong. I get the 
> >> flooding
> >> issue so I'm fine with just printing it once.
> > 
> > I disagree, but then I'm the one who wrote it in the first place, so
> > you wouldn't expect me to agree. :-) Let's see what Stephen says.
> 
> Hi Lorenzo
> 
> Would it be acceptable to have a separate column which displays the 
> result of the sock destroy operation per socket.
> State    ... Killed
> ESTAB         Y
> TIME_WAIT     N
> 
> If it is not supported from kernel, maybe print U (unsupported) for 
> this.

When you guys come to a conclusion, then I will review the result.
Right now neither solution looks good.
