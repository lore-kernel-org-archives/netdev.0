From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCHv2  2/2]: net/ipv{4,6}: reduce code size by inlining
Date: Tue, 14 Nov 2006 12:50:33 +0000
Message-ID: <200611141250.33918@strip-the-willow>
References: <200611140849.18324@strip-the-willow> <200611141327.22170.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:62933 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S965556AbWKNMun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 07:50:43 -0500
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200611141327.22170.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Andi Kleen:
|  On Tuesday 14 November 2006 09:49, Gerrit Renker wrote:
|  > [UDP]: Reduce size of shared code
|  > 
|  > This patch reduces size of source code files by moving
|  > some of the smaller functions shared by UDP and UDP-Lite
|  > into the header file udp_impl.h, and in-lining these.
|  > 
|  > It is an optimisation and applies on top of the previous
|  > UDP-Lite patch.
|  
|  Wouldn't it be better to just call them? They all don't 
|  particularly time critical.
This patch was sent as an optional add-on, it is not as important
as the other one. You are probably right - I also noted that the
gains (in terms of line numbers) are not as high as intended.
