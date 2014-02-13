From: Rick Jones <rick.jones2@hp.com>
Subject: Intermittent lockups creating/manipulating network namespaces (was
  Re: large degradation in ip netns add/exec performance in 3.13?)
Date: Thu, 13 Feb 2014 10:02:24 -0800
Message-ID: <52FD08B0.2050102@hp.com>
References: <52F1461D.8050703@hp.com> <52FAA3A6.9050608@hp.com> <52FAC6D1.50702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:34630 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbaBMSC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 13:02:26 -0500
Received: from g9t2301.houston.hp.com (g9t2301.houston.hp.com [16.216.185.78])
	by g4t0016.houston.hp.com (Postfix) with ESMTP id C14EF14003
	for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 18:02:25 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g9t2301.houston.hp.com (Postfix) with ESMTP id EC83C5C
	for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 18:02:24 +0000 (UTC)
In-Reply-To: <52FAC6D1.50702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2014 04:56 PM, Rick Jones wrote:
> On 02/11/2014 02:26 PM, Rick Jones wrote:
>> I did have the system lockup once at 16 concurrent streams on the 3.13.0
>> kernel.  Didn't happen the next two times I tried.
>
> I've had it happen again with a slightly tweaked ("heavier") fake router
> creation.  I'm guessing the attached soft lockup messages are related
> and may help point somewhere.

The 16 concurrent streams lockup.  The "rest of the system" keeps going.

I've had the same hang happen with 3.14.0-rc2 as well.  I was able to 
take a crash dump via "echo c > /proc/sysrq-trigger" but I have no clue 
how to look at it.  More than willing to upload it to netperf.org.

rick jones
