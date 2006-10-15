From: James Morris <jmorris@namei.org>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Sun, 15 Oct 2006 17:35:11 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610151729210.14523@d.namei>
References: <200610151820.22867.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:20888 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1161184AbWJOVfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Oct 2006 17:35:24 -0400
To: Dawid Ciezarkiewicz <dpc@asn.pl>
In-Reply-To: <200610151820.22867.dpc@asn.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 15 Oct 2006, Dawid Ciezarkiewicz wrote:

> Hi,
>  I'd be thankful for your opinions about that idea. Please forgive me any
> nuances that I didn't know about.

This limits the system to only talking to one other system on the same 
link.  I guess you could have per-MAC keys and associate the crypto info 
with neighbor cache entries.

Likely need a cryptographer to review the protocol -- blindly using the 
first block of every encrypted packet as the IV smells problematic, for 
example.


- James
-- 
James Morris
<jmorris@namei.org>
