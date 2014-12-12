From: Nils Holland <nholland@tisys.org>
Subject: Re: tg3 broken in 3.18.0?
Date: Fri, 12 Dec 2014 21:31:34 +0100
Message-ID: <20141212203134.GA23705@teela.fritz.box>
References: <20141210230634.GA22884@teela.fritz.box>
 <5489CA3C.10803@gmail.com>
 <548B00CD.3030708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jonathan Bither <jonbither@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from celine.tisys.org ([85.25.117.166]:35897 "EHLO celine.tisys.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932438AbaLLUbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 15:31:38 -0500
Content-Disposition: inline
In-Reply-To: <548B00CD.3030708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2014 at 09:50:53AM -0500, Jonathan Bither wrote:
> Not sure if it helps any, but tg3 works here after a 3.18 upgrade. I'd 
> be happy to share any information if it would help you out.

What I get here is this (output captured under 3.17.3):

triton513 ~ # ethtool -i enp2s0
driver: tg3
version: 3.137
firmware-version: sb
bus-info: 0000:02:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: no
supports-register-dump: yes
supports-priv-flags: no

So, you, Marcelo and me, we all seem to have different firmware
versions. If I'm correct, different versions of tg3 exist that either
contain the firmware onboard or get it injected at driver
initialization (correct me if I'm wrong). If Marcelo's and my fw
version had been the same this might have given a clue, but nope.

I'm putting my faith in Marcelo bisecting and finding out more details.
I might try that as well over the weekend, at least to the extent
possible without ever being able to have live access to the machine
when it is running a kernel exhibiting this issue.

Greetings,
Nils
