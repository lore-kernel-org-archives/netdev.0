From: Pavel Simerda <psimerda@redhat.com>
Subject: Re: [PATCH iproute2] tipc: introduce TIPC configuration tool
Date: Thu, 4 Jun 2015 06:23:35 -0400 (EDT)
Message-ID: <1689829731.5883859.1433413415372.JavaMail.zimbra@redhat.com>
References: <1431004056-6282-1-git-send-email-richard.alpe@ericsson.com> <20150521144340.1b112c0a@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: richard alpe <richard.alpe@ericsson.com>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx6-phx2.redhat.com ([209.132.183.39]:59854 "EHLO
	mx6-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbbFDKXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 06:23:48 -0400
In-Reply-To: <20150521144340.1b112c0a@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
> From: "Stephen Hemminger" <stephen@networkplumber.org>
> To: "richard alpe" <richard.alpe@ericsson.com>
> Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
> Sent: Thursday, May 21, 2015 11:43:40 PM
> Subject: Re: [PATCH iproute2] tipc: introduce TIPC configuration tool
> 
> On Thu, 7 May 2015 15:07:35 +0200
> <richard.alpe@ericsson.com> wrote:
> 
> > From: Richard Alpe <richard.alpe@ericsson.com>
> > 
> > This is the new tipc tool that utilizes the relativly new TIPC netlink API
> > in
> > the kernel. Introducing this tool into iproute2 has been discussed
> > previously.
> > 
> > For more information about the design decisions of this tool, see the
> > README
> > file.
> > 
> > There isn't yet a manpage for the this tool. I will start to write one once
> > I
> > submitted this for review.
> > 
> > Richard Alpe (1):
> >   tipc: add new TIPC configuration tool
> 
> I went ahead and merged this.
> It does add dependency on libmnl which the distribution maintainers will have
> to add to their stuff.

Does the new dependency suggest the whole iproute2 is moving to libmnl? Or is
there a good reason to use an external netlink library as well as an internal one?

Cheers,

Pavel

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
