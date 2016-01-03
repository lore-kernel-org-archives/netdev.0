From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 2/2] arpd: fix parsing of unlikely long
 comments
Date: Sun, 3 Jan 2016 15:04:25 -0800
Message-ID: <20160103150425.79f05a52@xeon-e3>
References: <20160103090404.054e724b@xeon-e3>
	<1451846374-2665-1-git-send-email-andreas@fatal.se>
	<1451846374-2665-2-git-send-email-andreas@fatal.se>
	<20160103184429.GA2713@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35345 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbcACXEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 18:04:16 -0500
Received: by mail-pa0-f49.google.com with SMTP id do7so2039038pab.2
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2016 15:04:16 -0800 (PST)
In-Reply-To: <20160103184429.GA2713@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 3 Jan 2016 19:44:29 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> Hello Stephen Hemminger.
> 
> Please beware that this has been compile-tested only.
> Submitting it like this was what I was trying to avoid
> by just throwing in a FIXME comment in the initial submission.
> Sorry in advance if I managed to screw something up, but
> hopefully I didn't...
> 
> Regards,
> Andreas Henriksson
> 

All this seems like overkill. The file format for arpd is very simple:
ifindex, IPv4, MAC
and really should never be too long. If it is the input is garbage and the
whole input should just be rejected, logged, and arpd should exit.
