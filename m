From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 17:58:19 -0400
Message-ID: <482CB1FB.7080807@garzik.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <a24804730805151301s3c6644d0hc2c78b8008fe035d@mail.gmail.com> <20080515214721.GP18825@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Theodore Tso <tytso@mit.edu>,
	Chris Peterson <cpeterso@cpeterso.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@i
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43865 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbYEOV6g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 17:58:36 -0400
In-Reply-To: <20080515214721.GP18825@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Theodore Tso wrote:
> On Thu, May 15, 2008 at 01:01:36PM -0700, Chris Peterson wrote:
>> Please correct me if I'm wrong, but this thread's conclusions seem to be:
>>
>> * network interrupts are an inappropriate source of entropy (see my patch)
>> * headless servers need entropy, but should seek a better solution,
>> such as EGD, hardware RNG, or other kernel entropy sources (but that
>> is a separate task)
>> * TPM RNG is a separate task and, if implemented, should be in
>> drivers/char/hw_random/
> 
> The TPM RNG task is probably best done in a user space process, which
> might also do other things like pulling environmental noise from the
> sound card's microphone, etc.
> 
> The problem is finding someone with the skills, time, and energy to
> create the appropriate user space daemon.  All of the kernel
> interfaces already exist; it's just matter of implementing the user
> space support.

rngd is already deployed in most distros, via rng-tools.  Motivated 
people are welcome to steal maintainership from me...

	Jeff


