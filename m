From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 0/4] Introduce Mellanox Technologies Switch
 ASICs switchdev drivers
Date: Fri, 24 Jul 2015 07:38:13 +0200
Message-ID: <20150724053813.GE2178@nanopsycho.orion>
References: <1437666216-3149-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bB-1LcnzvEegiHQ=6OKZ3tJVkTkyENFC1Th5XjSS4CMBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, idosch@mellanox.com,
	eladr@mellanox.com,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Graf <tgraf@suug.ch>, ast@plumgrid.com,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	"simon.horman@netronome.com" <simon.horman@netronome.com>,
	John Linville <linville@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:37801 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbbGXFiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 01:38:16 -0400
Received: by wibud3 with SMTP id ud3so12368566wib.0
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 22:38:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bB-1LcnzvEegiHQ=6OKZ3tJVkTkyENFC1Th5XjSS4CMBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 24, 2015 at 02:03:20AM CEST, sfeldma@gmail.com wrote:
>On Thu, Jul 23, 2015 at 8:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> This patchset introduces Mellanox Technologies Switch driver infrastructure
>> and support for SwitchX-2 ASIC.
>>
>> The driver is divided into 3 logical parts:
>> 1) Bus - implements switch bus interface. Currently only PCI bus is
>>    implemented, but more buses will be added in the future. Namely I2C
>>    and SGMII.
>>    (patch #2)
>> 2) Driver - implemements of ASIC-specific functions.
>>    Currently SwitchX-2 ASIC is supported, but a plan exists to introduce
>>    support for Spectrum ASIC in the near future.
>>    (patch #4)
>> 3) Core - infrastructure that glues buses and drivers together.
>>    It implements register access logic (EMADs) and takes care of RX traps
>>    and events.
>>    (patch #1 and #3)
>>
>> Ido Schimmel (1):
>>   mlxsw: Add interface to access registers and process events
>>
>> Jiri Pirko (3):
>>   mlxsw: Introduce Mellanox switch driver core
>>   mlxsw: Add PCI bus implementation
>>   mlxsw: Introduce Mellanox SwitchX-2 ASIC support
>
>This is awesome!  Reviewing...

Thanks!


>
>checkpatch.pl shows 1 ERROR, bunch of >80 chars WARNs, and bunch of
>CHECKs on space after cast.

Those >80char WARNs are mostly macro "\" on col 81. That is afaik ok.
Maybe that should be changed in checkpatch as well.

The error is false possitive. It is again in macro, checkpatch thinks it
is a function and yells about "{" on the same line. However it is a
struct initialization so in that case it is ok.


>
>On the CHECKs on space after cast, should we modify checkpatch.pl to
>not flag those for drivers/net?

I agree.


>
>-scott
