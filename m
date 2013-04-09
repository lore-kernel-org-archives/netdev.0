From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: be2net: GRO for non-inet protocols
Date: Tue, 9 Apr 2013 16:22:39 +0200
Message-ID: <20130409142239.GB27063@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
 <1365175702.3405.2.camel@edumazet-glaptop>
 <1365175872.3405.3.camel@edumazet-glaptop>
 <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
 <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
 <1365436285.3887.16.camel@edumazet-glaptop>
 <20130409075532.GA20363@eerihug-hybrid.ki.sw.ericsson.se>
 <1365515075.3887.122.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:49539 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760876Ab3DIO1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 10:27:45 -0400
Content-Disposition: inline
In-Reply-To: <1365515075.3887.122.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 09, 2013 at 06:44:35AM -0700, Eric Dumazet wrote:
> I suggested you try GRE tunnels on emulex NIC, to make sure the problem
> is not coming from your changes. Nevermind ...
>
I understood that, but since i could not load anything newer than 3.0.61 on them,
GRO support for GRE tunnels was not included.. but anyway...
I got hold of a new set of machines that i could load 3.8 and perform the GRE 
test on, these also use Emulex NIC's.
What i found was that all packets received on the GRE device are MTU-sized, 
and are not GRO'd together at all. The same thing happens in a qemu environment, 
so maybe there's another issue with GRO for GRE..

//E
