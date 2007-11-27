From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 10:58:38 +0100
Message-ID: <20071127095838.GA2772@ff.dom.local>
References: <716567.82573.qm@web51408.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joerg Pommnitz <pommnitz@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:54225 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753464AbXK0JyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 04:54:05 -0500
Content-Disposition: inline
In-Reply-To: <716567.82573.qm@web51408.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 01:28:43AM -0800, Joerg Pommnitz wrote:
> Jarek,
> iptables chains (this is what I think you are referring to) are not the issue.

Yes, but this could (wrongly) look like this according to my 1-st message.

> This
> is about the qdisc that sits immediately over the device driver and decides the
> order waiting packets are sent over the line/air/carrier pigeon/... .
> My suspicion is that skb->priority used to be set to a value that derived from the
> TOS bits. Then something changed and nobody noticed.

I'm not sure of your problem: did you try this on a box which
gets packets with TOS set earlier, does forwarding, and uses this
prio on egress? If so, and this doesn't work, then you are right
something could be wrong.

Regards,
Jarek P.
