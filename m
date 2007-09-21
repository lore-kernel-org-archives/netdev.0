From: Ben Greear <greearb@candelatech.com>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 14:18:41 -0700
Message-ID: <46F43531.5040501@candelatech.com>
References: <1190359905.3551.28.camel@magi.nadr>	 <1190375946.4261.42.camel@localhost>  <1190379015.3551.57.camel@magi.nadr>	 <1190381841.4231.10.camel@localhost> <1190382366.4231.13.camel@localhost>	 <46F3E695.7010604@candelatech.com> <1190409160.4231.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Emil Micek <emil.micek@tkrjasek.cz>,
	"auke-jan.h.kok@intel.com" <auke-jan.h.kok@intel.com>,
	netdev mailing list <netdev@vger.kernel.org>,
	Jesse <jesse.brandeburg@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:56985 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753827AbXIUVSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 17:18:52 -0400
In-Reply-To: <1190409160.4231.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2007-21-09 at 08:43 -0700, Ben Greear wrote:
> 
>> I just re-read the spec, and a bridge *may* pad up to 68, but it is not 
>> required.
>> On page 166, it says equipment must be able to handle 64 byte minimums.
>>
>> See page 22 (section 7.2) of this document:
>>
>> http://standards.ieee.org/getieee802/download/802.1Q-1998.pdf
>>
>> Also, page 63, 165, 166
> 
> Thanks for the enlightnment. 
> Do we need an ethtool interface to turn off hardware accelerated vlans?
> Jesse is indicating that the intel hardware can only handle the MUST but
> not the SHOULD of the spec.
> Actually a more basic question: Can you select one or the other mode in
> the software based vlans?

It's not even clear to me that it's a Should..more like a 'May', for what
thats worth.

As for using the software stack, I don't think we are padding to 68 in
the soft vlans either...

It would be nice to have an ethtool to turn off hw vlans for other reasons,
like sniffing vlan tags, at least...

You cannot select hw v/s soft vlans...the code always uses hw-accel if it's
available, as far as I know.

Thanks,
Ben

> 
> cheers,
> jamal
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

