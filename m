From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: Fix broken RX checksums.
Date: Sun, 30 Oct 2016 23:53:42 -0400 (EDT)
Message-ID: <20161030.235342.134481656830778556.davem@davemloft.net>
References: <9fb6be7b-95f3-6e59-c0f4-1d6c3357416d@pobox.com>
        <20161030.205755.1198665157526465556.davem@davemloft.net>
        <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: mlord@pobox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1f847ae0-4928-01e7-f1e7-3cbc37529961@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mark Lord <mlord@pobox.com>
Date: Sun, 30 Oct 2016 22:07:25 -0400

> On 16-10-30 08:57 PM, David Miller wrote:
>> From: Mark Lord <mlord@pobox.com>
>> Date: Sun, 30 Oct 2016 19:28:27 -0400
>> 
>>> The r8152 driver has been broken since (approx) 3.16.xx
>>> when support was added for hardware RX checksums
>>> on newer chip versions.  Symptoms include random
>>> segfaults and silent data corruption over NFS.
>>>
>>> The hardware checksum logig does not work on the VER_02
>>> dongles I have here when used with a slow embedded system CPU.
>>> Google reveals others reporting similar issues on Raspberry Pi.
>>>
>>> So, disable hardware RX checksum support for VER_02, and fix
>>> an obvious coding error for IPV6 checksums in the same function.
>>>
>>> Because this bug results in silent data corruption,
>>> it is a good candidate for back-porting to -stable >= 3.16.xx.
>>>
>>> Signed-off-by: Mark Lord <mlord@pobox.com>
>> 
>> Applied and queued up for -stable, thanks.
> 
> Thanks.  Now that this is taken care of, I do wonder if perhaps
> RX checksums ought to be enabled at all for ANY versions of this chip?

You should really start a dialogue with the developer who has been
making the most, if not all, of the major changes to this driver over
the past few years, Hayes Wang.
