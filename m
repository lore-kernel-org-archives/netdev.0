From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Runtime power management for network interfaces
Date: Mon, 31 Jul 2006 09:19:18 -0700
Message-ID: <44CE2D86.3040800@intel.com>
References: <Pine.LNX.4.44L0.0607251147040.6498-100000@iolanthe.rowland.org>	<44C644B6.20208@intel.com> <20060730200631.836bdd23.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stern@rowland.harvard.edu, netdev@vger.kernel.org,
	david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64905 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1030217AbWGaQUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 12:20:45 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
In-Reply-To: <20060730200631.836bdd23.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> On Tue, 25 Jul 2006 09:20:06 -0700 Auke Kok wrote:
> 
>> Alan Stern wrote:
>>> During a Power Management session at the Ottawa Linux Symposium, it was
>>> generally agreed that network interface drivers ought to automatically
>>> suspend their devices (if possible) whenever:
>>>
>>>     (1) The interface is ifconfig'ed down, or
>>>
>>>     (2) No link is available.
>>>
>>> Presumably (1) should be easy enough to implement.  (2) might or might not
>>> be feasible, depending on how much WOL support is available.  (It might
>>> not be feasible at all for wireless networking.)  Still, there can be no
>>> question that it would be a Good Thing for laptops to power-down their
>>> ethernet controllers when the network cable is unplugged.
>>>
>>> Has any progress been made in this direction?  If not, a natural approach 
>>> would be to start with a reference implementation in one driver which 
>>> could then be copied to other drivers.
>>
>> Intel's newer e1000's (ich7 onboard e1000 and newer versions for instance) 
>> already support this feature partially - the MAC stays on but the PHY can be 
>> powered off when no link is present.
>>
>> In order to enable this feature you will need to turn it on explicitly at load 
>> time:
>>
>> modprobe e1000 SmartPowerDownEnable=1
> 
> Please add that to Documentation/networking/e1000.txt.

I'm long overdue with documentation updates ATM, I'll see if I can fix that :)

Cheers,

Auke
