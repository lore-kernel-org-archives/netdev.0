From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 9/9] bnx2x: annotate nvram dword reading/writing
Date: Thu, 22 Jan 2009 10:18:42 -0800
Message-ID: <1232648322.9701.55.camel@brick>
References: <1232517051.9701.27.camel@brick>
	 <1232646600.29087.90.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:4436 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753886AbZAVSSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 13:18:47 -0500
Received: by an-out-0708.google.com with SMTP id c2so519842anc.1
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 10:18:44 -0800 (PST)
In-Reply-To: <1232646600.29087.90.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-01-22 at 19:50 +0200, Eilon Greenstein wrote:
> On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> > I believe this exposed an endian bug as the shifting of
> > bytes from the data buffer was done in cpu-order, then
> > masked into a be32 and the combined value was then converted
> > to cpu-order, this does all the masking in be-byteorder and
> > passes a cpu-ordered value to the write routine.
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> 
> This change is breaking the FW upgrade utility which uses this interface
> since it is changing the content. I will need to work with the engineer
> that owns this utility, but this change will probably stay out for a
> while
> 

No worries, can you explain briefly what the code is trying to accomplish?
Maybe it was written assuming a le-machine, because this is going to
work differently on a be-machine.

Harvey

