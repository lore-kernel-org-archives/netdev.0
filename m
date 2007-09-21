From: jamal <hadi@cyberus.ca>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 17:29:47 -0400
Message-ID: <1190410187.4231.43.camel@localhost>
References: <1190359905.3551.28.camel@magi.nadr>
	 <1190375946.4261.42.camel@localhost>  <1190379015.3551.57.camel@magi.nadr>
	 <1190381841.4231.10.camel@localhost> <1190382366.4231.13.camel@localhost>
	 <46F3E695.7010604@candelatech.com> <1190409160.4231.29.camel@localhost>
	 <46F435CD.1090502@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Emil Micek <emil.micek@tkrjasek.cz>,
	netdev mailing list <netdev@vger.kernel.org>,
	Jesse <jesse.brandeburg@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:60168 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759640AbXIUV3u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 17:29:50 -0400
Received: by wx-out-0506.google.com with SMTP id h31so766815wxd
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 14:29:49 -0700 (PDT)
In-Reply-To: <46F435CD.1090502@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-21-09 at 14:18 -0700, Ben Greear wrote:

> As for using the software stack, I don't think we are padding to 68 in
> the soft vlans either...

Should be much easier than changing firmware or an ASIC.

> It would be nice to have an ethtool to turn off hw vlans for other reasons,
> like sniffing vlan tags, at least...

Hrm, no hardware out there will pass on tags to the stack as metadata?

On Fri, 2007-21-09 at 14:21 -0700, Kok, Auke wrote:

> I don't actually see the "SHOULD" part you are referring to. 

the "optional" part;-> MAY?

> AFAIK the RX side is fully covered 

so you can handle both 64B and 68B?

> and only on TX the hardware sends out 64b padded vlan packets, which
> is permitted. The spec never says that it is required to send out 68b padded vlan
> packets - only permits either choice.

The CISCO i pointed to seems to be only capable of 68B. So if the CISCO
sends to you, it would work, but you sending to the CISCO or to Emil's
CMTS you have challenges, no?


cheers,
jamal

