From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii matching
 table
Date: Wed, 06 Feb 2008 07:12:51 -0500
Message-ID: <47A9A443.2020109@pobox.com>
References: <1200476230-14026-1-git-send-email-sr@denx.de> <1200477239.6755.21.camel@pasglop> <20080116090110.1b7b2f00@zod.rchland.ibm.com> <200801300716.52463.sr@denx.de> <1201734898.8146.0.camel@pasglop> <20080205151216.4ff3c32a@weaponx>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, Stefan Roese <sr@denx.de>,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46661 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762038AbYBFMNI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 07:13:08 -0500
In-Reply-To: <20080205151216.4ff3c32a@weaponx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Josh Boyer wrote:
> On Thu, 31 Jan 2008 10:14:58 +1100
> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> 
>> On Wed, 2008-01-30 at 07:16 +0100, Stefan Roese wrote:
>>> On Wednesday 16 January 2008, Josh Boyer wrote:
>>>> On Wed, 16 Jan 2008 20:53:59 +1100
>>>>
>>>> Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
>>>>> On Wed, 2008-01-16 at 10:37 +0100, Stefan Roese wrote:
>>>>>> With the removal the the "rgmii-interface" device_type property from
>>>>>> the dts files, the newemac driver needs an update to only rely on
>>>>>> compatible property.
>>>>>>
>>>>>> Signed-off-by: Stefan Roese <sr@denx.de>
>>>>> I need to test if it works on CAB, can't change the DT on those. I'll
>>>>> let you know tomorrow.
>>>> This should be fine on CAB.  The rgmii node has:
>>>>
>>>> compatible = "ibm,rgmii-axon", "ibm,rgmii"
>>>>
>>>> so the match should still catch on the latter.
>>> How about this patch? Ben, if you think this is ok then we should make sure 
>>> that it goes in in this merge-window, since the other dts patch relies on it.
>> It's fine.
> 
> Jeff, any chance this can get into .25 soon?  I have another patch
> queued up behind this one that requires it, and I don't see it in any
> of your trees or branches.
> 
> Or, if you aren't opposed, I can take it through Paul's tree with your
> Ack.

can you resend?  I don't see it in the pile


