From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 9773] New: pptp/ppp connection die at high
  speed on Athlon X2 6000+
Date: Sat, 19 Jan 2008 19:26:06 +0100
Message-ID: <479240BE.5010105@gmail.com>
References: <bug-9773-10286@http.bugzilla.kernel.org/> <20080117234809.fc3f6cca.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Paul Mackerras <paulus@samba.org>, wizard580@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:38638 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978AbYASSWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 13:22:46 -0500
Received: by nf-out-0910.google.com with SMTP id g13so140120nfb.21
        for <netdev@vger.kernel.org>; Sat, 19 Jan 2008 10:22:44 -0800 (PST)
In-Reply-To: <20080117234809.fc3f6cca.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote, On 01/18/2008 08:48 AM:

> On Thu, 17 Jan 2008 23:33:54 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=9773
>>
>>            Summary: pptp/ppp connection die at high speed on Athlon X2 6000+
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.23.12


...

>> kernel 2.6.24rc8 makes it worst. As I see it just hangs my console with message
>> something like "waiting for ppp0 finish" or so... I don't remember exactly
>> message.

Could you please:

- check this after echo 1 > /proc/sys/kernel/sched_compat_yield
- check this with 2.6.22

Regards,
Jarek P.
