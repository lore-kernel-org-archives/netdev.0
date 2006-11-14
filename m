From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCHv2  2/2]: net/ipv{4,6}: reduce code size by inlining
Date: Tue, 14 Nov 2006 13:27:22 +0100
Message-ID: <200611141327.22170.ak@suse.de>
References: <200611140849.18324@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:42193 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S965419AbWKNM11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 07:27:27 -0500
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
In-Reply-To: <200611140849.18324@strip-the-willow>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 14 November 2006 09:49, Gerrit Renker wrote:
> [UDP]: Reduce size of shared code
> 
> This patch reduces size of source code files by moving
> some of the smaller functions shared by UDP and UDP-Lite
> into the header file udp_impl.h, and in-lining these.
> 
> It is an optimisation and applies on top of the previous
> UDP-Lite patch.

Wouldn't it be better to just call them? They all don't 
particularly time critical.

-Andi

