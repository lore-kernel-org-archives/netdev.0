From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] net: add init-regs for of_phy support
Date: Mon, 17 Feb 2014 13:50:28 +0000
Message-ID: <530213A4.4030400@codethink.co.uk>
References: <1392642484-19938-1-git-send-email-ben.dooks@codethink.co.uk> <1392642484-19938-2-git-send-email-ben.dooks@codethink.co.uk> <20140217134448.GA19308@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20140217134448.GA19308@e106331-lin.cambridge.arm.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/02/14 13:44, Mark Rutland wrote:
> On Mon, Feb 17, 2014 at 01:08:04PM +0000, Ben Dooks wrote:
>> Add new init-regs field for of_phy nodes and make sure these
>> get applied when the phy is configured.
>>
>> This allows any phy node in an fdt to initialise registers
>> that may not be set as standard by the driver at initialisation
>> time, such as LED controls.
>
> Why not have a driver for the particular PHY? If it's not standard we
> don't need to pretend it is. If it has some extensions then the standard
> compatible string can be a fallback entry in the compatible list.

I was trying to provide some useful and reasonably generic code
to setup PHYs without having to add specific arguments to each of
them.

I could have added something like ksz8041,led-mode1 = <1> and
updated the micrel driver.

-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
