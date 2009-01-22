From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH 9/9] bnx2x: annotate nvram dword reading/writing
Date: Thu, 22 Jan 2009 19:50:00 +0200
Message-ID: <1232646600.29087.90.camel@lb-tlvb-eliezer>
References: <1232517051.9701.27.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: "Harvey Harrison" <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3279 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759463AbZAVRvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2009 12:51:06 -0500
In-Reply-To: <1232517051.9701.27.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> I believe this exposed an endian bug as the shifting of
> bytes from the data buffer was done in cpu-order, then
> masked into a be32 and the combined value was then converted
> to cpu-order, this does all the masking in be-byteorder and
> passes a cpu-ordered value to the write routine.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

This change is breaking the FW upgrade utility which uses this interface
since it is changing the content. I will need to work with the engineer
that owns this utility, but this change will probably stay out for a
while


