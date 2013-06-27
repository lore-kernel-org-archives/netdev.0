From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch net-next 0/5] net: introduce generic type and
 helpers for IP address
Date: Thu, 27 Jun 2013 16:08:30 +0800
Message-ID: <1372320510.26333.7.camel@cr0>
References: <1372315398-19683-1-git-send-email-amwang@redhat.com>
	 <51CBE3AA.5070008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43964 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752286Ab3F0IIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 04:08:39 -0400
In-Reply-To: <51CBE3AA.5070008@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-27 at 09:03 +0200, Daniel Borkmann wrote:
> Hi Amerigo,
> 
> On 06/27/2013 08:43 AM, Cong Wang wrote:
> > As IPv6 becomes popular, more and more subsystems begin to support IPv6,
> > therefore we need a generic IP address type, in case of duplicates.
> > Also we will also need some helpers to compare, print, check the generic
> > IP address.
> >
> > This patchset introduce a new type union inet_addr as a union of IPv4
> > and IPv6 address, and some helper functions that will be used by existing
> > code and in the future VXLAN module.
> >
> > This patchset only does compile test, since it is still RFC.
> 
> This patch already does that which I've sent yesterday before yours ...
> 
>    [PATCH net-next 1/2] lib: vsprintf: add IPv4/v6 generic %pig/%pIg format specifier
> 
> ... and resend with the set today in the morning as v2 with provided
> feedback applied. Can't you base yours on top of that?

Since your patch is not yet merged, so why not just drop yours (of
course, if no objection for mine)? :)

IOW, even if your patch got merged, then I would probably partially
revert it when I rebase mine on top of yours, which seems ugly, right?

Again, I have no objection to your patch, just I don't want to partially
revert it when I rebase on top of it.

What do you think?
