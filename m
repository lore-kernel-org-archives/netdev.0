From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2] kaweth: Fix locking to be SMP-safe
Date: Tue, 31 Mar 2009 10:24:08 -0500
Message-ID: <49D23598.8050906@lwfinger.net>
References: <49d00512.XAF19LdpY1dlK6+U%Larry.Finger@lwfinger.net> <200903310939.09690.oliver@neukum.org> <49D22EFC.1020709@lwfinger.net> <200903311713.05451.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([204.127.217.104]:44122 "EHLO
	fmailhost04.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762688AbZCaPY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 11:24:56 -0400
In-Reply-To: <200903311713.05451.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum wrote:
> 
> This sounds like kaweth_tx_timeout() should have been called.
> Did you enable enough logging to see
> dev_warn(&net->dev, "%s: Tx timed out. Resetting.\n", net->name);

No, that one did not print.

My initial level of debugging was to #define DEBUG. When the dbg() macros didn't
trigger, I included a local copy of that one and then saw those messages.

>From my reading of include/linux/device.h, dev_warn() should always be enabled.
Did I miss something?

Larry

