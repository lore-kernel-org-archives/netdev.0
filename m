From: Nadejda Levitsky <maximlevitsky@gmail.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Fri, 6 Jun 2008 12:27:47 +0300
Message-ID: <200806061227.47844.nadejdalevitsky@gmail.com>
References: <200806011515.14103.maximlevitsky@gmail.com> <200806060031.16827.maximlevitsky@gmail.com> <m3hcc7ufgn.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:58301 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714AbYFFJ14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 05:27:56 -0400
Received: by ik-out-1112.google.com with SMTP id c28so509376ika.5
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2008 02:27:52 -0700 (PDT)
In-Reply-To: <m3hcc7ufgn.fsf@ursa.amorsen.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, 6 June 2008 11:37:12 Benny Amorsen wrote:
> Maxim Levitsky <maximlevitsky@gmail.com> writes:
> 
> > This seems the right solution,
> > if this is possible, why not to check for stuck TCP connections
> > on resume?
> 
> Imagine a laptop on wireless going into suspend for a few minutes,
> then getting woken up. If you're lucky today, the TCP connections
> survive.
It depends, I for example don't care about TCP connecions survival during suspend
I would even like to close them on suspend. (I usially use web browser, chat client, mail
maybe a download running in background which can be resumed)

Like I said such feature can be user configured.
There are uses like hibernating your server to change power supply, and still save all
TCP connections.



> 
> If you check for stuck TCP connections right after resume, you could
> have problems because the wireless hasn't negotiated encryption keys
> at that point. Isn't that a concern?

Good point, I haven't thought about this.
This means that a in-kernel solution is no-go, but userland solution
can check for such connections _after_ negotiation of wireless keys.

Or, just close all remote TCP connections if the suspend was long enough.



> 
> 
> /Benny
> 

Best regards,
	Maxim Levitsky
