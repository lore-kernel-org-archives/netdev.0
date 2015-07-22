From: Michael Tuexen <tuexen@fh-muenster.de>
Subject: Re: [RFC net-next 1/1] : sctp: denoise deprecation log on SCTP_EVENTS
Date: Wed, 22 Jul 2015 14:30:32 +0200
Message-ID: <24639F82-1D2F-4D12-AF1C-415F87D0A182@fh-muenster.de>
References: <559E4F17.9090107@mojatatu.com> <063D6719AE5E284EB5DD2968C1650D6D1CB6952D@AcuExch.aculab.com> <55AF86B2.1020001@iogearbox.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2102\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:38989 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964939AbbGVMaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 08:30:35 -0400
In-Reply-To: <55AF86B2.1020001@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On 22 Jul 2015, at 14:04, Daniel Borkmann <daniel@iogearbox.net> wrote:
> 
> On 07/22/2015 01:48 PM, David Laight wrote:
>> From: Jamal Hadi Salim
>>> Sent: 09 July 2015 11:38
>>> 
>>> In the newer kernels this message is extremely noisy. After a quick
>>> discussion with Daniel it seems to me it will be very hard to get
>>> existing apps that nobody is going to update to continue to work
>>> (i.e no forward compat). And newer apps that desire to play in both
>>> older kernels and new kernels will have to play some tricks to work
>>> (i.e weak backward compatibility).  These are good reasons
>>> to totally get rid of this message. At minimal to neutre it.
>>> The attached change tries to do that. However, if you had multiple
>>> apps, you will only get warning for the first one.
>> 
>> Never mind spanning the kernel log, there will be performance
>> issues with systems that are sending significant amounts of SCTP data.
>> I'm not sure you'll get 10000+/sec through the trace system.
> 
> What do you mean by "trace system" (there's no backtrace)?
> 
> Anyway, as previously stated, I doubt we'd get rid of the deprecated
> SCTP uapi from the RFC any time soon, so, imho, we should just remove
> these rate-limited messages altogether to stop spamming the klog ...
... and we will not remove it in FreeBSD either.

Best regards
Michael
> 
>> I'm going to have to find which version this trace went into and
>> make sure we tell customers not to use the relevant kernel versions.
>> 
>> 	David
>> 
> 
> 
