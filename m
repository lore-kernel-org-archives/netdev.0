From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 07/45] CPU hotplug: Provide APIs to prevent CPU offline
 from atomic context
Date: Mon, 11 Feb 2013 01:04:16 +0530
Message-ID: <5117F638.9070700@linux.vnet.ibm.com>
References: <20130122073210.13822.50434.stgit@srivatsabhat.in.ibm.com> <20130122073446.13822.39253.stgit@srivatsabhat.in.ibm.com> <87mwvsuw68.fsf@sejong.aot.lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org, peterz@infradead.org,
	fweisbec@gmail.com, linux-kernel@vger.kernel.org, mingo@kernel.org,
	linux-arch@vger.kernel.org, linux@arm.linux.org.uk,
	xiaoguangrong@linux.vnet.ibm.com, wangyun@linux.vnet.ibm.com,
	paulmck@linux.vnet.ibm.com, nikunj@linux.vnet.ibm.com,
	linux-pm@vger.kernel.org, rusty@rustcorp.com.au,
	rostedt@goodmis.org, rjw@sisk.pl, tglx@linutronix.de,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	oleg@redhat.com, sbw@mit.edu, tj@kernel.org,
	akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org
To: Namhyung Kim <namhyung@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:52455 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760856Ab3BJTgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 14:36:23 -0500
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Mon, 11 Feb 2013 05:29:21 +1000
In-Reply-To: <87mwvsuw68.fsf@sejong.aot.lge.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Namhyung,

On 01/29/2013 03:51 PM, Namhyung Kim wrote:
> Hi Srivatsa,
> 
> On Tue, 22 Jan 2013 13:04:54 +0530, Srivatsa S. Bhat wrote:
>> @@ -246,15 +291,21 @@ struct take_cpu_down_param {
>>  static int __ref take_cpu_down(void *_param)
>>  {
>>  	struct take_cpu_down_param *param = _param;
>> -	int err;
>> +	unsigned long flags;
>> +	int err = 0;
> 
> It seems no need to set 'err' to 0.
>

Sorry for the late reply. This mail got buried in my inbox and
I hadn't noticed it until now.. :-(

I'll remove the unnecessary initialization. Thank you!

Regards,
Srivatsa S. Bhat
