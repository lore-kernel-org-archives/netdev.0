From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] jme: fix irq storm after suspend/resume
Date: Mon, 24 Oct 2011 02:58:22 -0400 (EDT)
Message-ID: <20111024.025822.548298031734112062.davem@davemloft.net>
References: <20111022125620.GA2256@ecki.lan>
	<j7uqst$kpc$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: grawity@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <j7uqst$kpc$1@dough.gmane.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Mantas M." <grawity@gmail.com>
Date: Sat, 22 Oct 2011 19:27:09 +0300

> On 22/10/11 15:56, Clemens Buchacher wrote:
>> If the device is down during suspend/resume, interrupts are enabled
>> without a registered interrupt handler, causing a storm of
>> unhandled interrupts until the IRQ is disabled because "nobody
>> cared".
>>
>> Instead, check that the device is up before touching it in the
>> suspend/resume code.
>>
>> Fixes https://bugzilla.kernel.org/show_bug.cgi?id=39112
> 
> Just tested the patch, suspend/resume works well.

Applied, thanks.
