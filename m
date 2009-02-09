From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [BUG BISECTED] boot hangs while bringing up gianfar ethernet
Date: Mon, 09 Feb 2009 14:36:15 +0100
Message-ID: <87prhr7mwg.fsf@macbook.be.48ers.dk>
References: <20090207225555.GA2680@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ira Snyder <iws@ovro.caltech.edu>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:50541 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbZBINgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 08:36:48 -0500
In-Reply-To: <20090207225555.GA2680@ami.dom.local> (Jarek Poplawski's message of "Sat\, 7 Feb 2009 23\:55\:56 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Jarek" == Jarek Poplawski <jarkao2@gmail.com> writes:

 Jarek> Ira Snyder wrote, On 01/29/2009 08:41 PM:
 >> Hello,
 >> 
 >> I'm working on a Freescale MPC8349EMDS board. I have been booting it
 >> over NFS for a long time now. I try to run the latest git kernels to
 >> find possible problems.
 >> 
 >> Recently, I haven't been able to boot over NFS anymore. When the machine
 >> tries to bring up the ethernet interface, it just hangs forever. There
 >> are no softlockup warnings, the machine has locked up completely.
 >> 
 >> Here is the commit I bisected it down to. I tried running git revert,
 >> but there have been other changes which prevent an easy revert.
 >> 
 >> After building each kernel, I compiled and used the dts file from that
 >> kernel. There shouldn't be any conflicts there.

 Jarek> Hi,

 Jarek> Could you try this patch?

Solves the problem for me - Thanks. I'm not familar enough with the hw
to know if's the right fix, but it certainly fixes the nfsboot issue
for me.

-- 
Bye, Peter Korsgaard
