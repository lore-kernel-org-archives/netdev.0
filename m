From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: BUG/ spinlock lockup, 2.6.24
Date: Fri, 15 Feb 2008 22:03:26 +0100
Message-ID: <47B5FE1E.5080804@gmail.com>
References: <20080215150044.M24489@visp.net.lb> <e2e108260802150724k4e5e6089mcb603b524157a9bc@mail.gmail.com> <20080215193854.M55147@visp.net.lb> <47B5F462.40603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>,
	Bart Van Assche <bart.vanassche@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:42977 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765682AbYBOU7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 15:59:49 -0500
Received: by ug-out-1314.google.com with SMTP id z38so1340155ugc.16
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 12:59:47 -0800 (PST)
In-Reply-To: <47B5F462.40603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 02/15/2008 09:21 PM:

> Denys Fedoryshchenko wrote, On 02/15/2008 08:42 PM:
> ...
> 
>> I have similar crashes on completely different hardware with same job (QOS), 
>> so i think it is actually some nasty bug in networking.
> 
> Maybe you could try with some other debugging options? E.g. since lockdep
> doesn't help - turn this off. Instead try some others, like these:

...On the other hand this:

> Feb 15 15:50:17 217.151.X.X [1521315.068984] BUG: spinlock lockup on CPU#1, 
> ksoftirqd/1/7, f0551180

seems to point just at spinlock lockup, so it's more about the full report.
I wonder if this patch to prink could help here:

author	Ingo Molnar <mingo at elte.hu>
	Fri, 25 Jan 2008 20:07:58 +0000 (21:07 +0100)
printk: make printk more robust by not allowing recursion

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=32a76006683f7b28ae3cc491da37716e002f198e

Jarek P.
