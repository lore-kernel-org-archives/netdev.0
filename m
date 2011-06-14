From: Ben Greear <greearb@candelatech.com>
Subject: Re: [E1000-devel] [PATCH] e100: Fix inconsistency in bad frames handling
Date: Tue, 14 Jun 2011 12:05:09 -0700
Message-ID: <4DF7B0E5.1020404@candelatech.com>
References: <BANLkTimpYniHhN6ccMXN7Lx3xDdK6sC+FQ@mail.gmail.com>	 <alpine.WNT.2.00.1106060940010.3568@JBRANDEB-DESK2.amr.corp.intel.com>	 <4DED14E7.2050405@candelatech.com>  <1307391315.22348.454.camel@localhost>	 <1307392197.2642.14.camel@edumazet-laptop>	 <4DF79AB1.2080109@candelatech.com> <1308077828.4651.5.camel@jbrandeb-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andrea Merello <andrea.merello@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54869 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699Ab1FNTF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 15:05:27 -0400
In-Reply-To: <1308077828.4651.5.camel@jbrandeb-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2011 11:57 AM, Brandeburg, Jesse wrote:
> On Tue, 2011-06-14 at 10:30 -0700, Ben Greear wrote:
>>>> How would a received skb be flagged as having a CRC error?
>>>>
>>>
>>> maybe some skb->pkt_type = PACKET_INVALID; or something...
>>
>> Jesse:  If I can get the ethtool related patches accepted, would
>> you accept patches to e100 (and other Intel drivers) for
>> this feature?
>
> seems like a reasonable thing, but, there is some risk that might
> prevent us turning this on however, because we often like our hardware
> to discard bad frames because (especially) long ones can use quite a few
> buffers.
>
> I still am generally uncomfortable with this idea.  We've survived a
> long time without it and it opens up the possibility of extra bugs (like
> possible security issues, etc) with very little opportunity for
> worthwhile gain.

If we make it require root permissions to enable this, and disable
it by default, will that be enough allay your fears?

Also, could print msg to kernel logs when enabling this.

I think that we could skip any intrusive changes (ie, if allowing
rx of long packets is a big problem, just don't allow that for
that particular driver.)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

