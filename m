From: Justin Pettit <jpettit@nicira.com>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Wed, 8 Sep 2010 16:13:51 -0700
Message-ID: <72E610F4-6157-47CA-B409-92CE151843A8@nicira.com>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de> <201009082058.15533.sven.eckelmann@gmx.de> <AANLkTi=FVyLE6OHTd+_qDbzSLk6fY5j6wBOWkYA810Dj@mail.gmail.com> <201009082225.47498.sven.eckelmann@gmx.de>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Jesse Gross <jesse@nicira.com>, b.a.t.m.a.n@lists.open-mesh.org,
	Andi Kleen <andi@firstfloor.org>, davem@davemloft.net,
	netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.net
To: Sven Eckelmann <sven.eckelmann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:40187 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095Ab0IHXN6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 19:13:58 -0400
Received: by pvg2 with SMTP id 2so249785pvg.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 16:13:57 -0700 (PDT)
In-Reply-To: <201009082225.47498.sven.eckelmann@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sep 8, 2010, at 1:25 PM, Sven Eckelmann wrote:

> Without checking any facts: This sounds a little bit heavy - does it only 
> sound heavy and in reality is extreme slim? The problem is that it must run on 
> those low end, "please don't run code on me, because I cannot crunch numbers 
> and have no ram" machines like the FON2100 or WRT54GL.


We used to run early versions of Open vSwitch on the WRTSL54GS (which is only a bit beefier than the WRT54GL) and didn't have any problems.  My guess is that it would run even better now, since the code has gone through a number of optimizations.  If packets are hitting the kernel cache, it's really only header parsing and a hash lookup, which is pretty cheap.

--Justin


