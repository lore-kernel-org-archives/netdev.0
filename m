From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH net 2/2] DT: phy.txt: Clarify expected compatible values
Date: Wed, 27 Jan 2016 09:32:27 -0800
Message-ID: <CAOesGMipfjA9nO8Oe5J_672Xz7nKmR4UAPnoYCBzcZKDiQDFZA@mail.gmail.com>
References: <1453853499-11248-1-git-send-email-andrew@lunn.ch>
	<1453853499-11248-3-git-send-email-andrew@lunn.ch>
	<CAOesGMj6OKYY6thjKX_t-ABogSNrSuQ7rbWPPvhGRtdOTJtXiQ@mail.gmail.com>
	<20160127171109.GE20194@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Aaro Koskinen <aaro.koskinen@nokia.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f196.google.com ([209.85.160.196]:35426 "EHLO
	mail-yk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932303AbcA0Rc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 12:32:28 -0500
Received: by mail-yk0-f196.google.com with SMTP id a85so1102286ykb.2
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 09:32:28 -0800 (PST)
In-Reply-To: <20160127171109.GE20194@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2016 at 9:11 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, Jan 27, 2016 at 08:41:56AM -0800, Olof Johansson wrote:
>> On Tue, Jan 26, 2016 at 4:11 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> > PHY devices may only list clause 22, 45, and their PHY identifier
>> > values as compatible values. No other compatible strings are allowed.
>> > Make this clear in the documentation, and remove examples where
>> > make/model compatible strings are listed.
>> >
>> > Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>>
>> I'm not sure I agree with the disallowing here. It's common practice
>> to use a specific compatible to describe the actual hardware used, in
>> case it's needed in the future for some driver to distinguish
>> behavior, etc.
>>
>> So while it should be required to include the clause compats, having a
>> more specific one in there should be acceptable.
>
> Hi Olof
>
> Matching PHY devices to drivers has never used to compatible string,
> other than the "ethernet-phy-XXXX.YYYY" string.  The PHY has two
> registers containing a manufacture id, device id and revision,
> registers 2 and 3. These are the XXXX and YYYY. The core code reads
> these values, or uses the values from the ethernet-phy-XXXX.YYYY, and
> uses them to find a driver which supports these values.
>
> A make/model string is less specific than ethernet-phy-XXXX.YYYY.
>
> I will reword the changelog to make it clear that
> "ethernet-phy-XXXX.YYYY" is allowed.

Only case I can see the need for a make/model string is if there's a
need to add model-specific properties since you'd need a compatible
then (or make those properties shared between all phy bindings).


Anyway, we've never had a huge issue with this on other probable
busses, so we should be fine with the above. With the clarification
I'm OK with this change.


-Olof
