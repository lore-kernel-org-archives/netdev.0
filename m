From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/7] r8169: add a new chip for RTL8111G
Date: Tue, 02 Apr 2013 19:26:01 -0400 (EDT)
Message-ID: <20130402.192601.800808445795589231.davem@davemloft.net>
References: <20130401222235.GB19335@electric-eye.fr.zoreil.com>
	<2808A1ABA9A5470C8CB9534309588984@realtek.com.tw>
	<20130402232008.GB16612@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130402232008.GB16612@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 3 Apr 2013 01:20:08 +0200

> hayeswang <hayeswang@realtek.com> :
>> Francois Romieu [mailto:romieu@fr.zoreil.com] 
> [...]
>> > There is close to zero added value for this stuff in the kernel.
>> > You may as well move it completely into the firmware.
>> 
>> Do you mean all of the phy settings ? I have checked these settings with
>> our hw engineers. These are not firmware. 
> 
> Undocumented configuration data which is subject to change over time ?
> 
> No one outside of Realtek can make any sense of this opaque pile of data.
> There is no point in me or anybody else rubber stamping it for inclusion.

Right, so either document all of these indirect registers being programmed
in the PHY or move it to firmware.
