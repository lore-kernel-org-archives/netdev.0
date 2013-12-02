From: Mark Lord <mlord@pobox.com>
Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
Date: Mon, 02 Dec 2013 10:05:54 -0500
Message-ID: <529CA1D2.2070806@pobox.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com> <528A9A36.50903@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com> <20131119.161313.743887333007019981.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7439@saturn3.aculab.com> <20131120165420.GD9611@xanatos> <5299546B.2020800@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B744E@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	ming.lei@canonical.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:44999 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753Ab3LBPGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 10:06:02 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B744E@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-12-02 04:30 AM, David Laight wrote:
>> From: Mark Lord
>> Sent: 30 November 2013 02:59
>> To: Sarah Sharp; David Laight
>> Cc: David Miller; eric.dumazet@gmail.com; ming.lei@canonical.com; netdev@vger.kernel.org; linux-
>> usb@vger.kernel.org
>> Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
>>
>> On 13-11-19 08:44 AM, Mark Lord wrote:
>>> On 13-11-19 05:04 AM, David Laight wrote:
>>>>
>>>> Which changes did you revert?
>>>
>>> Just the bits that changed how the headroom/tailroom sizes
>>> were checked and adjusted.  See attachment for the revert patch
>>> I am using here.  My mailer unfortunately likes to mangle inline patches.
>>>
> ...
>>
>> Two kernels later, and this regression has still not been fixed.
>>
>> A simple revert, folks.
> 
> Reverting the ax88179_178a driver doesn't fix the problem.
> I'm seen tx/rx issues with it on much older kernels that don't
> appear with a current kernel and the fixed xhci code.
> 
> Sarah needs to feed the xhci_ring.c fix through into stable.

Oh, I agree.  But Linus makes a MASSIVE distinction between things
that have always been broken, and REGRESSIONS from the immediately
prior kernel that can be tracked to a single update.

Let's see some action, here folks!
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
