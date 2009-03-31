From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2] kaweth: Fix locking to be SMP-safe
Date: Tue, 31 Mar 2009 13:40:55 -0500
Message-ID: <49D263B7.4000409@lwfinger.net>
References: <49d00512.XAF19LdpY1dlK6+U%Larry.Finger@lwfinger.net> <200903310939.09690.oliver@neukum.org> <49D22EFC.1020709@lwfinger.net> <200903311713.05451.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([207.115.11.55]:57847 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762461AbZCaSlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 14:41:44 -0400
In-Reply-To: <200903311713.05451.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum wrote:
> 
> This sounds like kaweth_tx_timeout() should have been called.
> Did you enable enough logging to see
> dev_warn(&net->dev, "%s: Tx timed out. Resetting.\n", net->name);


The problem turned out to be an old, slow router that was locking, and not a
problem with kaweth. I'll resubmit my patches.

Larry
