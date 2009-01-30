From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [BUG BISECTED] boot hangs while bringing up gianfar ethernet
Date: Fri, 30 Jan 2009 15:57:15 +0100
Message-ID: <87bpton8ok.fsf@macbook.be.48ers.dk>
References: <20090129194145.GA4647@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:60323 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752048AbZA3O5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 09:57:20 -0500
In-Reply-To: <20090129194145.GA4647@ovro.caltech.edu> (Ira Snyder's message of "Thu\, 29 Jan 2009 11\:41\:45 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Ira" == Ira Snyder <iws@ovro.caltech.edu> writes:

 Ira> Hello,

 Ira> I'm working on a Freescale MPC8349EMDS board. I have been
 Ira> booting it over NFS for a long time now. I try to run the latest
 Ira> git kernels to find possible problems.

 Ira> Recently, I haven't been able to boot over NFS anymore. When the machine
 Ira> tries to bring up the ethernet interface, it just hangs forever. There
 Ira> are no softlockup warnings, the machine has locked up completely.

FYI, I'm seeing the same here (with a mpc8347) with all 2.6.29-rcX,
but I didn't have time to track it down yet.

-- 
Bye, Peter Korsgaard
