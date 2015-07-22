From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC net-next 1/1] : sctp: denoise deprecation log on SCTP_EVENTS
Date: Wed, 22 Jul 2015 14:04:02 +0200
Message-ID: <55AF86B2.1020001@iogearbox.net>
References: <559E4F17.9090107@mojatatu.com> <063D6719AE5E284EB5DD2968C1650D6D1CB6952D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 'Jamal Hadi Salim' <jhs@mojatatu.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	tuexen@fh-muenster.de
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54451 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964956AbbGVMEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 08:04:21 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB6952D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2015 01:48 PM, David Laight wrote:
> From: Jamal Hadi Salim
>> Sent: 09 July 2015 11:38
>>
>> In the newer kernels this message is extremely noisy. After a quick
>> discussion with Daniel it seems to me it will be very hard to get
>> existing apps that nobody is going to update to continue to work
>> (i.e no forward compat). And newer apps that desire to play in both
>> older kernels and new kernels will have to play some tricks to work
>> (i.e weak backward compatibility).  These are good reasons
>> to totally get rid of this message. At minimal to neutre it.
>> The attached change tries to do that. However, if you had multiple
>> apps, you will only get warning for the first one.
>
> Never mind spanning the kernel log, there will be performance
> issues with systems that are sending significant amounts of SCTP data.
> I'm not sure you'll get 10000+/sec through the trace system.

What do you mean by "trace system" (there's no backtrace)?

Anyway, as previously stated, I doubt we'd get rid of the deprecated
SCTP uapi from the RFC any time soon, so, imho, we should just remove
these rate-limited messages altogether to stop spamming the klog ...

> I'm going to have to find which version this trace went into and
> make sure we tell customers not to use the relevant kernel versions.
>
> 	David
>
