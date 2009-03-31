From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/2] kaweth: Fix locking to be SMP-safe
Date: Tue, 31 Mar 2009 09:55:56 -0500
Message-ID: <49D22EFC.1020709@lwfinger.net>
References: <49d00512.XAF19LdpY1dlK6+U%Larry.Finger@lwfinger.net> <200903300828.45337.oliver@neukum.org> <49D0EC24.4080206@lwfinger.net> <200903310939.09690.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost02.isp.att.net ([204.127.217.102]:55627 "EHLO
	fmailhost02.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbZCaO4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 10:56:45 -0400
In-Reply-To: <200903310939.09690.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum wrote:
> 
> Very good.
> 
>> (X server over the network), the interface stalled with no logged messages.
> 
> Do you get something with sysrq-t ?

No. The rest of the system was still functioning; however, the driver needed to
be unloaded and reloaded before continuing. There were no log entries until the
driver was unloaded.

Larry


