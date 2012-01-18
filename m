From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe: Unsupported SFP+ modules on 10Gbit/s X520-DA2 NIC?
Date: Wed, 18 Jan 2012 14:43:22 -0800
Message-ID: <4F174B0A.10208@candelatech.com>
References: <1326886258.19261.25.camel@probook>  <20120118091351.000052fc@unknown>  <m3d3ag7ki8.fsf@ursa.amorsen.dk> <1326925160.2795.45.camel@probook>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59881 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258Ab2ARWnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 17:43:42 -0500
In-Reply-To: <1326925160.2795.45.camel@probook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2012 02:19 PM, Jesper Dangaard Brouer wrote:
> On Wed, 2012-01-18 at 22:45 +0100, Benny Amorsen wrote:
>> Jesse Brandeburg<jesse.brandeburg@intel.com>  writes:
>>
>>> For X520 adapters, the documentation[1] states that which SFP+
>>> adapters are/are not supported.  Direct attach cables are also
>>> supported.
>>>
>>> [1] http://www.intel.com/support/network/adapter/pro100/sb/CS-030612.htm
>>
>> I can't believe that locked optics have now arrived on commodity
>> hardware. I have been trying to migrate to all-Intel networking at work;
>> that effort is certainly on hold now.
>
> I cannot understand why Intel are pulling a stunt like this! :-(
>
> I have read the code, and the limitation comes from a EEPROM setting on
> the NIC, see define "IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP 0x1".
>
> Here is a (untested) patch I believe removes the limitation in the
> driver:
>
>
> [PATCH] ixgbe: Always allow any SFP+ regardless of EEPROM setting.
>
> Intel are trying to limit which SFP's we can use in our NICs.
> We don't like this practices in the Linux Kernel.

I think that you should at least print some big warnings in
the kernel logs if you do this, as well as all the info you
can find on the non-supported SFP+ module in use so that folks can debug
things if the SFP+ doesn't properly work.

As previously mentioned, I found a case where some random SFP+
did NOT work with a similar hack in place...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
