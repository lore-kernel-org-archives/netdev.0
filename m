From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH iproute2] ss: Tell user about -EOPNOTSUPP for SOCK_DESTROY
Date: Tue, 17 May 2016 11:29:42 +0900
Message-ID: <CAKD1Yr0E9i0s0ocSyYhEjODnVVQVBPOfbepvORAhT9gi9Qqz6A@mail.gmail.com>
References: <1463442791-2399-1-git-send-email-dsa@cumulusnetworks.com>
 <1463442791-2399-2-git-send-email-dsa@cumulusnetworks.com>
 <CAKD1Yr08Zm55=oxMWUxL5-=D-gt4Hg5nfKSH7KRi38Ki=VyqcQ@mail.gmail.com>
 <bf9bfd17-9b96-dac4-a429-5470a44aa66c@cumulusnetworks.com>
 <CAKD1Yr2tzVATZLYV86KmvPvAohW2-49J+6Wc6PuP+xmLwBz9Qg@mail.gmail.com>
 <39db6a27-9dfa-1c9a-2699-2f01a0e64a66@cumulusnetworks.com>
 <CAKD1Yr3itVp4UgWF1uFSVRKzQm_vaLEQT=FnfBNjUJJVTj2Z+Q@mail.gmail.com> <3d0fd83a-fa88-8ceb-a44d-237f5a005eb4@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f178.google.com ([209.85.161.178]:34234 "EHLO
	mail-yw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbcEQCaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 22:30:02 -0400
Received: by mail-yw0-f178.google.com with SMTP id j74so2735582ywg.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 19:30:02 -0700 (PDT)
In-Reply-To: <3d0fd83a-fa88-8ceb-a44d-237f5a005eb4@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2016 at 11:24 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> As I mentioned we can print the unsupported once or per socket matched and
> with the socket params. e.g.,
>
> +               } else if (errno == EOPNOTSUPP) {
> +                       printf("Operation not supported for:\n");
> +                       inet_show_sock(h, diag_arg->f, diag_arg->protocol);
>
> Actively suppressing all error messages is just wrong. I get the flooding
> issue so I'm fine with just printing it once.

I disagree, but then I'm the one who wrote it in the first place, so
you wouldn't expect me to agree. :-) Let's see what Stephen says.
