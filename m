From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 14:21:17 -0700
Message-ID: <46F435CD.1090502@intel.com>
References: <1190359905.3551.28.camel@magi.nadr>	 <1190375946.4261.42.camel@localhost>  <1190379015.3551.57.camel@magi.nadr>	 <1190381841.4231.10.camel@localhost> <1190382366.4231.13.camel@localhost>	 <46F3E695.7010604@candelatech.com> <1190409160.4231.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Emil Micek <emil.micek@tkrjasek.cz>,
	netdev mailing list <netdev@vger.kernel.org>,
	Jesse <jesse.brandeburg@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26071 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761329AbXIUVVX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 17:21:23 -0400
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

I don't actually see the "SHOULD" part you are referring to. AFAIK the RX side is
fully covered and only on TX the hardware sends out 64b padded vlan packets, which
is permitted. The spec never says that it is required to send out 68b padded vlan
packets - only permits either choice.

Auke

