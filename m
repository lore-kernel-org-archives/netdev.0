From: jamal <hadi@cyberus.ca>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 17:12:40 -0400
Message-ID: <1190409160.4231.29.camel@localhost>
References: <1190359905.3551.28.camel@magi.nadr>
	 <1190375946.4261.42.camel@localhost>  <1190379015.3551.57.camel@magi.nadr>
	 <1190381841.4231.10.camel@localhost> <1190382366.4231.13.camel@localhost>
	 <46F3E695.7010604@candelatech.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Emil Micek <emil.micek@tkrjasek.cz>,
	"auke-jan.h.kok@intel.com" <auke-jan.h.kok@intel.com>,
	netdev mailing list <netdev@vger.kernel.org>,
	Jesse <jesse.brandeburg@intel.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:52292 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238AbXIUVMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 17:12:43 -0400
Received: by wx-out-0506.google.com with SMTP id h31so763864wxd
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 14:12:43 -0700 (PDT)
In-Reply-To: <46F3E695.7010604@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-21-09 at 08:43 -0700, Ben Greear wrote:

> I just re-read the spec, and a bridge *may* pad up to 68, but it is not 
> required.
> On page 166, it says equipment must be able to handle 64 byte minimums.
> 
> See page 22 (section 7.2) of this document:
> 
> http://standards.ieee.org/getieee802/download/802.1Q-1998.pdf
> 
> Also, page 63, 165, 166

Thanks for the enlightnment. 
Do we need an ethtool interface to turn off hardware accelerated vlans?
Jesse is indicating that the intel hardware can only handle the MUST but
not the SHOULD of the spec.
Actually a more basic question: Can you select one or the other mode in
the software based vlans?

cheers,
jamal


