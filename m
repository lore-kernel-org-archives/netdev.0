From: Andi Kleen <andi@firstfloor.org>
Subject: Re: hang after "registering protocol family 2" in linux-next
Date: Sat, 03 Jan 2009 04:20:40 +0100
Message-ID: <87eizljcs7.fsf@basil.nowhere.org>
References: <20090101043310.GA23765@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:56571 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751280AbZACDTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 22:19:11 -0500
Received: from basil.firstfloor.org (p5B3C86FA.dip0.t-ipconnect.de [91.60.134.250])
	by one.firstfloor.org (Postfix) with ESMTP id 4D6F31AD0021
	for <netdev@vger.kernel.org>; Sat,  3 Jan 2009 04:32:50 +0100 (CET)
In-Reply-To: <20090101043310.GA23765@basil.nowhere.org> (Andi Kleen's message of "Thu, 1 Jan 2009 05:33:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen <andi@firstfloor.org> writes:

> FYI,
>
> I booted today's linux-next and I got a hang somewhere in inet_init 
> (according to initcalL_debug) after Registering protocol family 2
>
> Haven't investigated further.

I did some investigation now and it seems to be related to TREE_RCU.
Goes away with CLASSIC. I'll report it to Paul.

-Andi

-- 
ak@linux.intel.com
