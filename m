From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [0/2] netxen: bug fix and diagnostics for possible (hardware?)
 bug
Date: Thu, 19 Dec 2013 09:11:33 +0000
Message-ID: <31AFFC7280259C4184970ABA9AFE8B938CF868E9@avmb3.qlogic.org>
References: <1387257753-18676-1-git-send-email-david@gibson.dropbear.id.au>
 <31AFFC7280259C4184970ABA9AFE8B938CF85726@avmb3.qlogic.org>
 <20131218062231.GB32453@voom.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"snagarka@redhat.com" <snagarka@redhat.com>,
	"tcamuso@redhat.com" <tcamuso@redhat.com>,
	"vdasgupt@redhat.com" <vdasgupt@redhat.com>
To: David Gibson <david@gibson.dropbear.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49298 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751075Ab3LSJLm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 04:11:42 -0500
In-Reply-To: <20131218062231.GB32453@voom.fritz.box>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> >From: David Gibson [mailto:david@gibson.dropbear.id.au]
>> >Sent: Tuesday, December 17, 2013 10:53 AM
>> >To: Manish Chopra; Sony Chacko; Rajesh Borundia
>> >Cc: netdev; snagarka@redhat.com; tcamuso@redhat.com;
>> >vdasgupt@redhat.com
>> >Subject: [0/2] netxen: bug fix and diagnostics for possible
>> >(hardware?) bug
>> >
>> >At Red Hat, we've hit a couple of customer cases with crashes in the
>> >netxen driver due to list corruption.  This seems to be very rarely
>> >triggered, and unfortunately the dumps we have don't have enough
>> >information to be certain of the cause, although we have a possible theory.
>> >
>> >I'm suggesting, therefore a patch to add some sanity checking which
>> >should help to at least localize and mitigate the problem when someone hits it
>in future.
>> >Please let me know if there's a better approach to doing this.
>> >
>> >That's 2/2.  1/2 is a fix for a clear bug I spotted along the way,
>> >but not one that could cause the symptoms we've seen.
>>
>> David,
>>
>> Having these checks in data path(Rx path) may have some performance
>> impact. It's better to root cause it instead of putting some sanity
>> checks.
>
>Obviously, but this was the best way I could think of to try narrowing down the
>root cause (at least trying to eliminate driver vs. firmware bug).

David, Instead of making permanent changes in driver, can you please run your modified driver in selective customer environment where this issues is seen?
Which may give some data point that what's the issue exactly and then we go by that.

>
>> We will get back to you on this.
>
>If you have a better idea for locating the root cause, please let me know.  I have
>access to a vmcore which I can poke around in.

We will also try to reproduce the problem in our environment and debug this.
Can you please give some details?

1) what's the driver and firmware version used?
2) which operating system and kernel version?
3) please send the vmcore also with backtrace if available which can give some idea what can trigger this issue.
4) Test case details:- what type of test is running on the system? Just to make sure we also try the same test cases in our environment.
5) Server details (Number of CPus, memory etc.) if available.

Thanks,
Manish
  
