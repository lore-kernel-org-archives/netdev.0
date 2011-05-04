From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Wed, 04 May 2011 18:09:21 +0200
Message-ID: <4DC17A31.8070409__32.0137748078153$1304525236$gmane$org@grandegger.com>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>	<201104271525.28512.arnd@arndb.de>	<15AD189F851849F69A011B6F4D1DDB6C@subhasishg>	<201105041511.54095.arnd@arndb.de>	<4DC163D7.9010309@grandegger.com> <20110504155750.GC322@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>,
	Subhasish Ghosh <subhasish@mistralsolutions.com>,
	linux-arm-kernel@lists.infradead.org,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	sachi@mistralsolutions.
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20110504155750.GC322@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Kurt,

On 05/04/2011 05:57 PM, Kurt Van Dijck wrote:
>>
>>> How hard would it be to implement that feature in Socket CAN?
>>
>> CAN controllers usually provide some kind of hardware CAN id filtering,
>> but in a very hardware dependent way. A generic interface may be able to
>> handle the PRUSS restrictions as well. CAN devices are usually
>> configured through the netlink interface. e.g.
>>
>>   $ ip link set can0 up type can bitrate 125000
>>
>> and such a common interface would be netlink based as well.
> ack.
>>
>>> Is that something that Subhasish or someone else could to as a prerequisite
>>> to merging the driver?
>>
>> Any ideas on how to handle hardware filtering in a generic way are
>> welcome. I will try to come up with a proposal sooner than later.
> 
> When doing so, I'd vote for an unlimited(by software) list of hardware filters (id/mask).
> The hardware must abort when no more filters are available.

Sounds good and not even to complicated. For the SJA1000 we would just
allow to set the global mask.

> I think that when using hardware filters, knowing the actual device
> with it's amount of hardware filters is the least of your problems.
> Userspace applications that suddenly stop working properly due to
> hw filters (i.e. some traffic not coming in anymore) will be a major
> source of bugreports.

Well, hardware filtering will be off by default and must explicitly be
set by the user, like for the bitrate setting.

Wolfgang.

