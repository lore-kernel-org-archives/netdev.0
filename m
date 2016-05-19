From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for
 SOCK_DESTROY
Date: Thu, 19 May 2016 08:19:40 -0700
Message-ID: <1463671180.18194.187.camel@edumazet-glaptop3.roam.corp.google.com>
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
	 <CAKD1Yr1u-p8hyjd_e672kYrXw+-Mkmj_Cxai=WUYM-9QQG=DQg@mail.gmail.com>
	 <4ca62c9f-4d19-4dd1-0d8c-c2cfe17c0443@cumulusnetworks.com>
	 <1463629667.18194.150.camel@edumazet-glaptop3.roam.corp.google.com>
	 <7b91db2e-9e27-48e3-e080-00037bc1a9c3@cumulusnetworks.com>
	 <1463631168.18194.153.camel@edumazet-glaptop3.roam.corp.google.com>
	 <2ad9d070-8326-a720-39d7-2e46db98ff7a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org, David Miller <davem@davemloft.net>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34000 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754603AbcESPTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 11:19:43 -0400
In-Reply-To: <2ad9d070-8326-a720-39d7-2e46db98ff7a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-19 at 08:06 -0600, David Ahern wrote:
> On 5/18/16 10:12 PM, Eric Dumazet wrote:
> > On Wed, 2016-05-18 at 22:05 -0600, David Ahern wrote:
> >
> >> You think it is ok to send a request to the kernel, the kernel says "I
> >> can't do it" and the command says nothing to the user? That is current
> >> behavior. How on Earth is that acceptable?
> >
> > I don't know. Tell me what is acceptable on a 'dump many sockets' and
> > some of them can be killed, but not all of them.
> >
> > What I do know is that you sent totally buggy patches.
> 
> buggy patches? not silently dropping a failure makes for a buggy patch?

You sent one kernel patch that was useless, then an iproute2 patch that
was simply aborting the dump.

Really, if you want fix things, do this properly instead of simply
ranting about work done by others, even if they are working for Google.

Thank you.
