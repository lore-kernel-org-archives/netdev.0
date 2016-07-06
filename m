From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 3/4] net: dsa: Suffix function manipulating device_node with _dn
Date: Tue, 05 Jul 2016 21:59:05 -0400
Message-ID: <87a8hvv85y.fsf@ketchup.mtl.sfl>
References: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com> <1467756433-25062-4-git-send-email-f.fainelli@gmail.com> <20160705223612.GC28825@lunn.ch> <577C3817.1070908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50175 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbcGFB7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 21:59:09 -0400
In-Reply-To: <577C3817.1070908@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Florian Fainelli <f.fainelli@gmail.com> writes:

> On 07/05/2016 03:36 PM, Andrew Lunn wrote:
>> On Tue, Jul 05, 2016 at 03:07:12PM -0700, Florian Fainelli wrote:
>>> Make it clear that these functions take a device_node structure pointer
>> 
>> Hi Florian
>> 
>> Didn't we agree that we would only support a single device via a C
>> coded platform data structure?
>
> That is true for the devices I know about, both in and out of tree,
> however, while discussing offline with Vivien it seemed like there was a
> potential need for having a x86-based platform which could need that,
> Vivien do you think this platform could be in-tree one day (if not already)?

This customer platform is not mainlined yet and I cannot say today if it
will be. However it is likely to get a new revision soon with 3
interconnected 6352 hanging the x86 Baytrail.

DT on x86 is possible, but not straight-forward, and thanks to Florian's
work the pdata support is almost there for free.

>> All the functions you are renaming will never be called in that
>> case. So i think they can retain there names. You have no need to add
>> none device node equivalents.
>> 
>> So lets drop this patch.

The patch is not big and I think it doesn't hurt to add that explicit
suffix, I'd keep the patch in the series.

Thanks,

        Vivien
