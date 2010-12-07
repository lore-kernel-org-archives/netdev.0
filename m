From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] Insert interrupt URB after resume, so that status
 transfers can flow.
Date: Mon, 06 Dec 2010 18:57:54 -0800
Message-ID: <1291690674.2285.229.camel@helium>
References: <1291630983-23725-1-git-send-email-Indrek.Peri@Ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Indrek Peri <Indrek.Peri@Ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm1-vm0.bullet.mail.ac4.yahoo.com ([98.139.53.202]:23065 "HELO
	nm1-vm0.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751905Ab0LGC56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 21:57:58 -0500
In-Reply-To: <1291630983-23725-1-git-send-email-Indrek.Peri@Ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Building on my comment about your other patch ... shouldn't this be just
another part of the "resume driver" action,
like refilling the RX urb queue?

For the same reasons ... NAK.  It looks like the work to add suspend and
resume processing to this driver had a few holes, and resume handling
can be simplified by combining re-activation of RX processing and this
status reporting (where relevant) in one routine.

- Dave



