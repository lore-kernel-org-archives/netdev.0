From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [v2] net:ethernet:cavium:octeon:octeon_mgmt: Handle return NULL
 error from devm_ioremap
Date: Wed, 14 Dec 2016 10:54:00 -0800
Message-ID: <262b3fdb-754b-a1f1-bd6a-3b15d72063b4@gmail.com>
References: <1481732732-6892-1-git-send-email-arvind.yadav.cs@gmail.com>
 <3c3d5968-bc41-e1b7-6fda-78e92e7a9d56@caviumnetworks.com>
 <0be48286-2656-84b4-4cd8-93bea5fbc6f0@gmail.com>
 <f113cad3-e368-679a-c56b-3c8c57e1a07b@caviumnetworks.com>
 <a4c42b7c-89bb-efa7-e6e6-86e620ee1897@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arvind Yadav <arvind.yadav.cs@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a4c42b7c-89bb-efa7-e6e6-86e620ee1897@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/14/2016 10:39 AM, arvind Yadav wrote:
> Hi David,
> 
> I have gave my comment.
> 
> Thanks
> Arvind
> 
> On Wednesday 14 December 2016 11:44 PM, David Daney wrote:
>> On 12/14/2016 10:06 AM, arvind Yadav wrote:
>>> Yes, I have seen this error. We have a device with very less memory.
>>> Basically it's OMAP2 board. We have to port Android L on this.
>>> It's has 3.10 kernel version. In this device, we were getting Page
>>> allocation failure.
>>
>> This makes absolutely no sense to me.  OCTEON is a mips64 SoC with a
>> ton of memory where ioremap can never fail, and it doesn't run
>> Android, and you are talking about OMAP2.
>           -I just gave as example where i have seen ioremap issue.
> Please don't relate. I know, Now it will not fail.  ioremap will through
> NULL on failure. We should catch this error. Even other driver of MIPS
> soc is having same check. It's just check which will not impact any
> functionality or performance of this driver. It will avoid NULL pointer
> error. We know, if  function is returning any error. we should catch.

Your patch subject should also be changed to insert spaces between
semicolon, so this would be:

net: ethernet: cavium: octeon: octeon_mgmt:
-- 
Florian
