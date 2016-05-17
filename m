From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH v2 2/2] phy dp83867: Make rgmii parameters optional
Date: Tue, 17 May 2016 22:37:36 +0200
Message-ID: <2C61E1D8-A99E-4B5D-A4CE-F2394A784889@suse.de>
References: <1463424763-58807-2-git-send-email-agraf@suse.de> <20160517.142224.1322153249705614542.davem@davemloft.net> <573B643A.9060700@ti.com> <20160517.144838.81367550225777134.davem@davemloft.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: dmurphy@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, michal.simek@xilinx.com,
	andrew@lunn.ch
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160517.144838.81367550225777134.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

> Am 17.05.2016 um 20:48 schrieb David Miller <davem@davemloft.net>:
> 
> From: Dan Murphy <dmurphy@ti.com>
> Date: Tue, 17 May 2016 13:34:34 -0500
> 
>> David
>> 
>>> On 05/17/2016 01:22 PM, David Miller wrote:
>>> From: Alexander Graf <agraf@suse.de>
>>> Date: Mon, 16 May 2016 20:52:43 +0200
>>> 
>>>> If you compile without OF_MDIO support in an RGMII configuration, we fail
>>>> to configure the dp83867 phy today by writing garbage into its configuration
>>>> registers.
>>>> 
>>>> On the other hand if you do compile with OF_MDIO and the phy gets loaded via
>>>> device tree, you have to have the properties set in the device tree, otherwise
>>>> we fail to load the driver and don't even attach the generic phy driver to
>>>> the interface anymore.
>>>> 
>>>> To make things slightly more consistent, make the rgmii configuration properties
>>>> optional and allow a user to omit them in their device tree.
>>>> 
>>>> Signed-off-by: Alexander Graf <agraf@suse.de>
>>> Applied.
>> 
>> This patch should not have been applied.
>> 
>> I did not believe the implementation was proper for that driver.
>> 
>> It seems my objection to the code was not seen.  Nor was Andrew's point about the DT bindings document
>> 
>> https://patchwork.kernel.org/patch/9105371/
> 
> The discussions around the recent phy patches have been a labrynth that I've
> found hard to follow, sorry.
> 
> I'll revert these two, sigh....

The first patch is an obvious and correct fix. Discussions were only about the second one (which I'm happy to drop given the rat hole this turned out to be).

Alex
