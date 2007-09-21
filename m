From: jamal <hadi@cyberus.ca>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 17:36:25 -0400
Message-ID: <1190410585.4231.46.camel@localhost>
References: <1190359905.3551.28.camel@magi.nadr>
	 <1190375946.4261.42.camel@localhost> <1190379015.3551.57.camel@magi.nadr>
	 <1190381841.4231.10.camel@localhost> <1190382366.4231.13.camel@localhost>
	 <46F3E695.7010604@candelatech.com> <1190409160.4231.29.camel@localhost>
	 <41b516cb0709211427s45cdd3b0pa0bb76d114d5f041@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Emil Micek <emil.micek@tkrjasek.cz>,
	"auke-jan.h.kok@intel.com" <auke-jan.h.kok@intel.com>,
	netdev mailing list <netdev@vger.kernel.org>,
	Jesse <jesse.brandeburg@intel.com>
To: Chris Leech <chris.leech@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:63853 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755275AbXIUVgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 17:36:31 -0400
Received: by wx-out-0506.google.com with SMTP id h31so767927wxd
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 14:36:29 -0700 (PDT)
In-Reply-To: <41b516cb0709211427s45cdd3b0pa0bb76d114d5f041@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-21-09 at 14:27 -0700, Chris Leech wrote:

> 
> Inserting the VLAN tag in software will not change the behavior in the
> way you want anyway, short frames will still be padded to 64 bytes.
> You'd have to do short packet padding in software to 68 bytes.  Or do
> software padding to 64 bytes and let the hardware insert the VLAN tag
> after.

I like the second one because it could be done totaly in the driver and
would resolve the problem IMO. All we need after is an ethtool knob to
select between 64B or 68B txmit.

cheers,
jamal

