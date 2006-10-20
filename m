From: Dawid Ciezarkiewicz <dpc@asn.pl>
Subject: Re: [RFC] wrr (weighted round-robin) bonding
Date: Fri, 20 Oct 2006 21:41:14 +0200
Message-ID: <200610202141.15140.dpc@asn.pl>
References: <200610162021.12884.dpc@asn.pl> <200610171016.21964.dpc@asn.pl> <20061019190407.GA23446@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.asn.pl ([85.14.104.1]:21124 "HELO apollo.asn.pl")
	by vger.kernel.org with SMTP id S1422748AbWJTTl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 15:41:26 -0400
To: Andy Gospodarek <andy@greyhouse.net>
In-Reply-To: <20061019190407.GA23446@gospo.rdu.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, 19 October 2006 21:04, Andy Gospodarek wrote:
> It would seem to me that extending an existing mode would be more
> desirable than adding yet another mode to worry about.  I don't even
> like the fact that there are as many as there are, but I understand why
> they are there.  

Ack. I will probably update wrr bonding patch to replace rr mode.

> I recently extended rr mode to allow an additional parameter called that
> rr_repeat that would allow someone to send more than a single frame out
> of each device before moving to the next one.  It seemed this could be
> helpful when dealing with switches that constantly re-learned source MAC
> addresses.  Network performance would suffer whenever rr_repeat was >1,
> but box performance might be better if there weren't so many locks
> taken.

Thanks. I'll consider adding such functionality.
