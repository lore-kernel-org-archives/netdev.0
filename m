From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for SOCK_DESTROY
Date: Fri, 20 May 2016 00:22:35 +0900
Message-ID: <CAKD1Yr0uo+H=4n+_DFV05g-0ca7UZAYcRR4Bb5ibRgNV1=ijZQ@mail.gmail.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
 <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr08Zm55=oxMWUxL5-=D-gt4Hg5nfKSH7KRi38Ki=VyqcQ@mail.gmail.com>
 <bf9bfd17-9b96-dac4-a429-5470a44aa66c@cumulusnetworks.com>
 <CAKD1Yr2tzVATZLYV86KmvPvAohW2-49J+6Wc6PuP+xmLwBz9Qg@mail.gmail.com>
 <39db6a27-9dfa-1c9a-2699-2f01a0e64a66@cumulusnetworks.com>
 <CAKD1Yr3itVp4UgWF1uFSVRKzQm_vaLEQT=FnfBNjUJJVTj2Z+Q@mail.gmail.com>
 <3d0fd83a-fa88-8ceb-a44d-237f5a005eb4@cumulusnetworks.com>
 <CAKD1Yr0E9i0s0ocSyYhEjODnVVQVBPOfbepvORAhT9gi9Qqz6A@mail.gmail.com>
 <a3cafb2342fa6a754fc389947f77f248@codeaurora.org> <CAKD1Yr1u-p8hyjd_e672kYrXw+-Mkmj_Cxai=WUYM-9QQG=DQg@mail.gmail.com>
 <4ca62c9f-4d19-4dd1-0d8c-c2cfe17c0443@cumulusnetworks.com>
 <1463629667.18194.150.camel@edumazet-glaptop3.roam.corp.google.com>
 <7b91db2e-9e27-48e3-e080-00037bc1a9c3@cumulusnetworks.com>
 <1463631168.18194.153.camel@edumazet-glaptop3.roam.corp.google.com> <2ad9d070-8326-a720-39d7-2e46db98ff7a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org, David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:36147 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbcESPW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 11:22:57 -0400
Received: by mail-yw0-f169.google.com with SMTP id x189so81303549ywe.3
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 08:22:57 -0700 (PDT)
In-Reply-To: <2ad9d070-8326-a720-39d7-2e46db98ff7a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 11:06 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> got it. Google does not care about users; don't un-suppress failures.

The users I was trying to care about are the ones that have correctly
configured kernels. It did not seem useful to those users to litter
the dumps with error messages saying that the kernel could not close a
socket that cannot be closed.
