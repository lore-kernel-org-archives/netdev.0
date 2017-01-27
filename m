From: =?UTF-8?Q?Sean_Nyekj=c3=a6r?= <sean.nyekjaer@prevas.dk>
Subject: Re: [PATCH v1] net: phy: micrel: add KSZ8795 ethernet switch
Date: Fri, 27 Jan 2017 08:42:39 +0100
Message-ID: <5f3fa323-bf36-5fcd-248f-a3b9ad70ea6d@prevas.dk>
References: <20170123075846.12888-1-sean.nyekjaer@prevas.dk>
 <20170123151219.GE10895@lunn.ch>
 <732c14ff-f0cf-67d5-bcf9-cbbf9a4391b3@prevas.dk>
 <20170126181207.GF5656@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02.prevas.se ([62.95.78.10]:42911 "EHLO mail02.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754247AbdA0IIY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 03:08:24 -0500
In-Reply-To: <20170126181207.GF5656@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017-01-26 19:12, Andrew Lunn wrote:
>> I remove the word "Switch" from the commit message and phy name.
>> The rest is okay?
> Yes.
>
>> What is generally being done when to phy's have the same id, micrel
>> have done this many times...
> It should not be a problem. When you write a switch driver for the
> switch, it will be in device tree. Look at the Marvell Switches as an
> example. Switches don't probe based on the ID in registers 2 and 3,
> because switches often respond to many different addresses, or don't
> have an ID in register 2 and 3.
>
> So it should not matter if the switch and the PHYs embedded in the
> switch have the same ID.
>
> When do you plan to post your switch driver?
>
>         Andrew
I was not planning on doing that, the managed part of the switch is not 
needed in the project i'm working on.
Maybe i will do it when i have some spare time, it could be fun :-)

/Sean
