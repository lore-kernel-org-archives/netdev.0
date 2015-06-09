From: Hyong-Youb Kim <hykim@myri.com>
Subject: Re: PROBLEM: there exists a wrong return value of function
 myri10ge_probe()
Date: Tue, 9 Jun 2015 20:52:44 +0900
Message-ID: <20150609115242.GA3732@hykim-PC>
References: <39f5faaa.db15.14dd801ed14.Coremail.zy900702@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: anna <zy900702@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0143.outbound.protection.outlook.com ([157.56.112.143]:8416
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932928AbbFIMJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 08:09:20 -0400
Content-Disposition: inline
In-Reply-To: <39f5faaa.db15.14dd801ed14.Coremail.zy900702@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2015 at 07:08:34PM +0800, anna wrote:
[...]
> mgp->sram_size satisfy the condition in line 4062, the value of
> status is 0. So the function myri10ge_probe() will return 0 to
> its caller functions when it runs error, leading to a wrong
> return value of function myri10ge_probe().

Okay, that is a bug.  I will try to prepare a patch.  Is this a real
problem for you (i.e. your setup is tripping this bug), or a
theoretical one you found via scripts or something?  If it is a real
problem, can you give me more context (e.g. NIC model, firmware
version)?

Also, I am going to need a proper "your name <address>", unless you do
not want your name in the patch.
