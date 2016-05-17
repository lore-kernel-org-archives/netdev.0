From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH v2 2/2] phy dp83867: Make rgmii parameters optional
Date: Tue, 17 May 2016 22:45:41 +0200
Message-ID: <F97BCB11-9AA8-4510-93CA-D8D1F4FF92A5@suse.de>
References: <1463424763-58807-2-git-send-email-agraf@suse.de> <20160517.142224.1322153249705614542.davem@davemloft.net> <573B643A.9060700@ti.com> <20160517.144838.81367550225777134.davem@davemloft.net> <2C61E1D8-A99E-4B5D-A4CE-F2394A784889@suse.de> <573B81A1.7000701@ti.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, michal.simek@xilinx.com,
	andrew@lunn.ch
To: Dan Murphy <dmurphy@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41037 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752AbcEQUpo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2016 16:45:44 -0400
In-Reply-To: <573B81A1.7000701@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> Am 17.05.2016 um 22:40 schrieb Dan Murphy <dmurphy@ti.com>:
> 
>> On 05/17/2016 03:37 PM, Alexander Graf wrote:
>> Hi David,
>> 
>>> Am 17.05.2016 um 20:48 schrieb David Miller <davem@davemloft.net>:
>>> 
>>> From: Dan Murphy <dmurphy@ti.com>
>>> Date: Tue, 17 May 2016 13:34:34 -0500
>>> 
>>>> David
>>>> 
>>>>> On 05/17/2016 01:22 PM, David Miller wrote:
>>>>> From: Alexander Graf <agraf@suse.de>
>>>>> Date: Mon, 16 May 2016 20:52:43 +0200
>>>>> 
>>>>>> If you compile without OF_MDIO support in an RGMII configuration, we fail
>>>>>> to configure the dp83867 phy today by writing garbage into its configuration
>>>>>> registers.
>>>>>> 
>>>>>> On the other hand if you do compile with OF_MDIO and the phy gets loaded via
>>>>>> device tree, you have to have the properties set in the device tree, otherwise
>>>>>> we fail to load the driver and don't even attach the generic phy driver to
>>>>>> the interface anymore.
>>>>>> 
>>>>>> To make things slightly more consistent, make the rgmii configuration properties
>>>>>> optional and allow a user to omit them in their device tree.
>>>>>> 
>>>>>> Signed-off-by: Alexander Graf <agraf@suse.de>
>>>>> Applied.
>>>> This patch should not have been applied.
>>>> 
>>>> I did not believe the implementation was proper for that driver.
>>>> 
>>>> It seems my objection to the code was not seen.  Nor was Andrew's point about the DT bindings document
>>>> 
>>>> https://patchwork.kernel.org/patch/9105371/
>>> The discussions around the recent phy patches have been a labrynth that I've
>>> found hard to follow, sorry.
>>> 
>>> I'll revert these two, sigh....
>> The first patch is an obvious and correct fix. Discussions were only about the second one (which I'm happy to drop given the rat hole this turned out to be).
> 
> So are you going to abandon the second patch all together?
> If you do, let me know I can submit a patch.

I'm fairly sure you'll be done with it much quicker than me and the real bug I wanted to fix is that the driver broke with OF_MDIO=m ;)

So yes, please take over from here.


Alex
