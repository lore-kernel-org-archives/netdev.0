From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Fri, 6 Jun 2008 00:31:16 +0300
Message-ID: <200806060031.16827.maximlevitsky@gmail.com>
References: <200806011515.14103.maximlevitsky@gmail.com> <20080604141533.35eb6df0@extreme> <484707D9.3040900@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Adam Langley <agl@imperialviolet.org>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:5869 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411AbYFEVbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 17:31:25 -0400
Received: by ug-out-1314.google.com with SMTP id h2so605768ugf.16
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2008 14:31:22 -0700 (PDT)
In-Reply-To: <484707D9.3040900@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 5 June 2008 00:23:37 Rick Jones wrote:
> > Another idea would be for the kernel to prematurely run the keepalive
> > timer for all TCP connections after resume. The keepalive code would send
> > an ACK (out of window) which causes other side to send a RST or ACK.
> > 
> > It is normal behaviour, the change would just make the timer happen sooner.
> 
> Would you have it done even for those endpoints on which SO_KEEPALIVE 
> wasn't set?

Why not?

This seems the right solution,
if this is possible, why not to check for stuck TCP connections
on resume?

Obviously, we should be able to turn this off, for some reasons, maybe some
weird servers, but generally this can be the default.

> 
> rick jones
> 

Best regards,
	Maxim Levitsky
