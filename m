From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] sh_net: runtime pm wrap mdio read and write
Date: Wed, 26 Feb 2014 18:25:01 +0000
Message-ID: <530E317D.3070807@codethink.co.uk>
References: <1393433319-22685-1-git-send-email-ben.dooks@codethink.co.uk> <530E3EBC.5060408@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com, magnus.damn@opensource.se,
	horms@verge.net.au
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <530E3EBC.5060408@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/02/14 19:21, Sergei Shtylyov wrote:
> On 02/26/2014 07:48 PM, Ben Dooks wrote:
>
>> On the R8A7790, if the device has been suspended by pm_runtime
>> and the MII code tries to access the bus then there is a possiblity
>
>     s/possiblity/possibility/.

ta, will fix.

>> that it will fail to read any data from the MII bus.
>
>> Change the MDIO read and write calls to be wrappered by calls to
>
>     s/wrappered/wrapped/.

ta.


>> pm_runtime_{get,put}_sync so that the device will be enabled during
>> these calls. It is put here to avoid having to enable and disable
>> the clock for every bit that is sent by the MII bit-banging code.
>
>> This has been exposed by the change to using OF and a fix to enable
>> the pm_runtime clock management which seems to have been broken for
>> some time for the device-tree booted Renesas kernels.
>
>     What fix to enable run-time PM are you talking about?

building drivers/sh/pm_runtime.c for the multiplatform case.


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
