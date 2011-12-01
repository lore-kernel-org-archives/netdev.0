From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH next-next 0/2] can: cc770: add support for the Bosch CC770
 and Intel AN82527
Date: Thu, 01 Dec 2011 08:47:35 +0100
Message-ID: <4ED73117.1020101@hartkopp.net>
References: <1322136448-7311-1-git-send-email-wg@grandegger.com>	<20111129.183950.1327835803051184146.davem@davemloft.net>	<4ED5CF14.4020502@hartkopp.net> <20111130.160727.1989923062226789802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Urs Thuermann <urs@isnogud.escape.de>
To: David Miller <davem@davemloft.net>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20111130.160727.1989923062226789802.davem@davemloft.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.11.2011 22:07, David Miller wrote:

> From: Oliver Hartkopp <socketcan@hartkopp.net>

>>>> Wolfgang Grandegger (2):
>>>>   can: cc770: add driver core for the Bosch CC770 and Intel AN82527
>>>>   can: cc770: legacy CC770 ISA bus driver
>>>
>>> All applied, thank you.
>>
>>
>> Hello Dave,
>>
>> this patchset was superseded for some time.
>>
>> We're currently in the v4 patchset (dated 2011-11-29).
>>
>> See http://patchwork.ozlabs.org/patch/128244/
>>
>> Do you want to revert the commit or should Wolfgang post a diff patch to get
>> to v4 ??
> 
> A not very good job was done here communicating to me what is happening.
> Endless revisions, and not clear indication to me what should or should
> not be applied as a result.


Well in this case i was just astonished why you applied a superseded patch set
- but i must admit that the pile-up of posted versions was a bit confusing.
Even there were platform and devtree patches that needed to be acked by other
maintainers - IMO we should post these patches on netdev only when they are
already acked by the platform/devtree guys.

@Wolfgang/Marc: We should return to discuss the CAN relevant patches on
linux-can@vger.kernel.org before posting them on netdev. Don't know why this
established & good process has changed over the time ...

> I want you guys to appoint someone to be the defacto CAN driver and
> subsystem maintainer who collects and merges all the driver and
> protocol patches into his tree, and acts as the one and only interface
> for me when changes are ready to be included.


I'm also not very happy someone else acking changes of my maintained sources -
sometimes it feels like Wild West to me, who's acking first :-(

To make it clear:

	Wolfgang Grandegger maintains drivers/net/can

and

	Oliver Hartkopp maintains net/can

As Marc Kleine-Budde is also very active in CAN driver development we should
probably add him to the drivers/net/can maintainers.

We'll continue the discussion on linux-can ML and give an update to the
MAINTAINERS file if we sorted out any changes. So far Wolfgang and me remain
the 'only interface' for you. Sorry for the traffic & confusion on netdev.

Regards,
Oliver
