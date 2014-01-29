From: Mark Lord <mlord@pobox.com>
Subject: Re: Help testing for USB ethernet/xHCI regression
Date: Tue, 28 Jan 2014 23:54:26 -0500
Message-ID: <52E88982.9070902@pobox.com>
References: <20140128203007.GA3311@xanatos> <52E883FB.7010704@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	David Laight <David.Laight@ACULAB.COM>
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:39318 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbaA2Ey2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 23:54:28 -0500
In-Reply-To: <52E883FB.7010704@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-01-28 11:30 PM, Mark Lord wrote:
> On 14-01-28 03:30 PM, Sarah Sharp wrote:
> ..
>> Can you please pull this branch, which contains a 3.13 kernel with
>> David's patch reverted, and test whether your USB ethernet device works
>> or fails?
> 
> Fails.  dmesg log attached.
> All I do is something akin to this:
> 
>    mount /server/ /x
>    mount --bind / /t
>    mirrordir -v --strict-mtimes /t /x/backups/empress
> 
> "mirrordir" is similar to "rsync", but less cryptic.
> The sequence above maintains a clone of the root filesystem
> of my ultrabook ("empress") on an NFS server over GigE.
> 
>> Also, please double check to see if vanilla 3.13 works or fails.
> 
> Okay, will try that before bed.

Vanilla 3.13 does not appear to have the USB3 ethernet lockup issue,
and even USB3 hot-plug appears to be working again (was not working in 3.13-rc4).

Cheers
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
