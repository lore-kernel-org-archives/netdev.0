From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next 0/2] can: cc770: add support for the Bosch
 CC770 and Intel AN82527
Date: Wed, 30 Nov 2011 16:07:27 -0500 (EST)
Message-ID: <20111130.160727.1989923062226789802.davem@davemloft.net>
References: <1322136448-7311-1-git-send-email-wg@grandegger.com>
	<20111129.183950.1327835803051184146.davem@davemloft.net>
	<4ED5CF14.4020502@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, socketcan-users@lists.berlios.de,
	boir1@yandex.ru, stanislavelensky@yahoo.com
To: socketcan@hartkopp.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4ED5CF14.4020502@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Hartkopp <socketcan@hartkopp.net>
Date: Wed, 30 Nov 2011 07:37:08 +0100

> On 30.11.2011 00:39, David Miller wrote:
> 
>> From: Wolfgang Grandegger <wg@grandegger.com>
>> Date: Thu, 24 Nov 2011 13:07:26 +0100
>> 
>>> Already since a while we have support for the Bosch CC770 and Intel
>>> AN82527 CAN controllers in our out-of-tree Socket-CAN repository.
>>> It would be nice if somebody could test the driver. Unfortunately,
>>> I currently do not have hardware at hand. I have not yet ported the
>>> OF platform driver as it needs further attaention due to the merge
>>> of the platform and OF platform interface.
>>>
>>> Wolfgang Grandegger (2):
>>>   can: cc770: add driver core for the Bosch CC770 and Intel AN82527
>>>   can: cc770: legacy CC770 ISA bus driver
>> 
>> All applied, thank you.
> 
> 
> Hello Dave,
> 
> this patchset was superseded for some time.
> 
> We're currently in the v4 patchset (dated 2011-11-29).
> 
> See http://patchwork.ozlabs.org/patch/128244/
> 
> Do you want to revert the commit or should Wolfgang post a diff patch to get
> to v4 ??

A not very good job was done here communicating to me what is happening.
Endless revisions, and not clear indication to me what should or should
not be applied as a result.

I want you guys to appoint someone to be the defacto CAN driver and
subsystem maintainer who collects and merges all the driver and
protocol patches into his tree, and acts as the one and only interface
for me when changes are ready to be included.

I sorted this out by reverting the older changes and applying V5.

But I had to fix things up, when applying patch #3 there are empty
trailing lines in some of the new files generated, and that causes
git to complain.
