From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works
 =?iso-8859-15?q?fine!=092=2E6=2E28?=
Date: Mon, 12 Jan 2009 20:58:22 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0901122052510.4748@ask.diku.dk>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
 <496AF0CE.7060406@trash.net> <200901121030.15782.denys@visp.net.lb>
 <200901122038.05199.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:59436 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642AbZALT6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:58:25 -0500
In-Reply-To: <200901122038.05199.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Jan 2009, Denys Fedoryschenko wrote:

> End of my story:
> 1000HZ solved issue. HTB and HFSC keeps rate MUCH better.
> Both looks like perform similar, but because it is real load scenario, i
> cannot measure which one is better.

If that was you problem, you should consider enabling 
CONFIG_HIGH_RES_TIMERS (and possibly CONFIG_NO_HZ).

Patrick McHardy has at some point made the sched code independent of the 
HZ value, but only when the HIGH_RES_TIMERS are enabled.

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
