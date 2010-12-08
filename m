From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [Bugme-new] [Bug 24472] New: Kernel panic - not syncing: Fatal
 Exception
Date: Wed, 08 Dec 2010 21:30:57 +0100
Message-ID: <4CFFEB01.7040700@itcare.pl>
References: <bug-24472-10286@https.bugzilla.kernel.org/> <20101208122233.835a4997.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pstaszewski@artcom.pl
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:53062 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756383Ab0LHUh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 15:37:27 -0500
In-Reply-To: <20101208122233.835a4997.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 2010-12-08 21:22, Andrew Morton pisze:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Wed, 8 Dec 2010 20:14:45 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> https://bugzilla.kernel.org/show_bug.cgi?id=24472
>>
>>             Summary: Kernel panic - not syncing: Fatal Exception
>>             Product: Drivers
>>             Version: 2.5
>>      Kernel Version: 2.6.36.1
>>            Platform: All
>>          OS/Version: Linux
>>                Tree: Mainline
>>              Status: NEW
>>            Severity: normal
>>            Priority: P1
>>           Component: Network
>>          AssignedTo: drivers_network@kernel-bugs.osdl.org
>>          ReportedBy: pstaszewski@artcom.pl
>>          Regression: No
>>
>>
>> Created an attachment (id=39332)
>>   -->  (https://bugzilla.kernel.org/attachment.cgi?id=39332)
>> Kernel Panic
>>
>> Hello i have problems with ppp driver and pppoe
>> I have random kernel panics
>>
>> In attached image is Call Trace from panic.
>>
>>
> ppp_unregister_channel() appears to be using a bad pointer.
> --

Yes.
I see kernel panics when connection is terminated - but this happend 
randomly
Sometimes to reproduce i need to connect->disconnect 50 - 60 times 
before kernel panic.



> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

