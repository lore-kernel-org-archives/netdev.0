From: Daniel Walker <danielwa@cisco.com>
Subject: Re: Marvell phy errata origins?
Date: Tue, 18 Apr 2017 07:35:21 -0700
Message-ID: <93efb026-adbf-d341-166b-90e19d9afb55@cisco.com>
References: <59691a35-a89c-f9ca-c7b0-73134a737f4c@cisco.com>
 <20170418140450.GB13724@lunn.ch>
 <3c16d944-9874-d016-e3f1-68055a22c173@cisco.com>
 <A00F2239C6748D4289A006FCD55C6D126F1901B7@XAP-PVEXMBX01.xlnx.xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andy Fleming <afleming@freescale.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        HEMANT RAMDASI <hramdasi@cisco.com>,
        "Julius Hemanth Pitti -X (jpitti - MONTA VISTA SOFTWARE INC at Cisco)"
        <jpitti@cisco.com>
To: Harini Katakam <harini.katakam@xilinx.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-6.cisco.com ([173.37.142.93]:31290 "EHLO
        alln-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753430AbdDROfY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:35:24 -0400
In-Reply-To: <A00F2239C6748D4289A006FCD55C6D126F1901B7@XAP-PVEXMBX01.xlnx.xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2017 07:31 AM, Harini Katakam wrote:
> Hi Daniel,
>
>> -----Original Message-----
>> From: Daniel Walker [mailto:danielwa@cisco.com]
>> Sent: Tuesday, April 18, 2017 7:48 PM
>> To: Andrew Lunn <andrew@lunn.ch>
>> Cc: Florian Fainelli <f.fainelli@gmail.com>; Andy Fleming
>> <afleming@freescale.com>; Harini Katakam <harinik@xilinx.com>;
>> netdev@vger.kernel.org; HEMANT RAMDASI <hramdasi@cisco.com>; Julius
>> Hemanth Pitti -X (jpitti - MONTA VISTA SOFTWARE INC at Cisco)
>> <jpitti@cisco.com>
>> Subject: Re: Marvell phy errata origins?
>>
>> On 04/18/2017 07:04 AM, Andrew Lunn wrote:
>>> On Tue, Apr 18, 2017 at 06:16:33AM -0700, Daniel Walker wrote:
> <snip>
>>>> In Harini's commit
>>>> message for ,
>>>>
>>>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/co
>>>> mmit/drivers/net/phy/marvell.c?id=3ec0a0f10ceb
>>>>
>>>> "This function has a sequence accessing Page 5 and Register 31, both
>>>> of which are not defined or reserved for this PHY"
>>>>
>>>> For the 88E1112 we see that these are "Factory Test Modes" which the
>>>> contents of are not documented. They aren't really "not defied", and
>>>> aren't really "reserved" .. Marvell support claims they don't support
>>>> these drivers, and Freescale seems to be adding these drivers, and
>>>> the line we are looking at.
>>>>
>>>> We had some issues with our PHY which were corrected with the same
>>>> patch Harini used but modified for the M88E1112. We're trying to get
>>>> to the bottom of where this code came from and what it was suppose to
>>>> be doing.
>>> I tried to find this errata fix in the Marvell reference code. And
>>> failed to find it. But it is "Vendor Crap" code, hard to find anything
>>> in it.
>>>
>>> My guess is, this errata just applies to one model of PHY, maybe even
>>> one revision of one model of a PHY. The hard bit is figuring out what
>>> actually needs it. Do you have access to Marvell datasheets?
> I have access to the datasheets for 88E1111, 88E1112 and 88E1116 (and another family 151x) -
> None of them have these register details or the errata documented.

http://www.dexsilicium.com/Marvell_88E1112.pd


Is this the same datasheet ? In this one on page 81 there is page 5 
register 31 is "Factory Test Modes" , do you not have that?

Daniel
