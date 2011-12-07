From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH net-next v6 4/4] powerpc: tqm8548/tqm8xx: add and update
 CAN device nodes
Date: Wed, 07 Dec 2011 09:25:03 +0100
Message-ID: <4EDF22DF.5020001@grandegger.com>
References: <1322732481-2255-1-git-send-email-wg@grandegger.com>	 <1322732481-2255-5-git-send-email-wg@grandegger.com> <1323243268.660.71.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-can@vger.kernel.org, linuxppc-dev@ozlabs.org,
	socketcan-users@lists.berlios.de
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1323243268.660.71.camel@pasglop>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/07/2011 08:34 AM, Benjamin Herrenschmidt wrote:
> On Thu, 2011-12-01 at 10:41 +0100, Wolfgang Grandegger wrote:
>> This patch enables or updates support for the CC770 and AN82527
>> CAN controller on the TQM8548 and TQM8xx boards.
> 
> I'm a bit confused by the net-next prefix here. Those patches seem to
> be only touching arch/powerpc and seem to be sent primarily toward
> netdev with a net-next prefix.

These patches are part of a series implementing a new netdev CAN driver
with device-tree support for CC770/i82527 CAN controllers. The
device-tree support and bindings are properly documented and some DTS
files have been updated accordingly. The relevant maintainers and
mailing list have been addressed.

> Also there have been at least 3 versions in a couple of days already
> without comments nor indication of what was changed...

Unfortunately, no response from those sub-system guys.

> Can you clarify things a bit please ? It looks like they really should
> go to linuxppc-dev (and you can probably drop a bunch of other lists) or
> am I missing an important piece of the puzzle ? (Such as patch 1/4 and
> 2/4 ...)

I have not sent the  whole series. The changes are documented in the
cover-letter, which I have not sent for those patches. Well, I think
it's better to sent the whole series to all parties instead?

> Let me know if I should just remove them from powerpc patchwork.

Dave has already applied all patches.

Sorry for the confusion. Any advice on how to handle multi subsystem
series of patches properly is welcome.

Wolfgang.
