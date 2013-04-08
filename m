From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: be2net: GRO for non-inet protocols
Date: Mon, 08 Apr 2013 08:51:25 -0700
Message-ID: <1365436285.3887.16.camel@edumazet-glaptop>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
	 <1365175702.3405.2.camel@edumazet-glaptop>
	 <1365175872.3405.3.camel@edumazet-glaptop>
	 <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
	 <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:58098 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934521Ab3DHPv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 11:51:29 -0400
Received: by mail-da0-f49.google.com with SMTP id t11so2626779daj.8
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 08:51:28 -0700 (PDT)
In-Reply-To: <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 17:24 +0200, Erik Hugne wrote:
> On Mon, Apr 08, 2013 at 08:40:10AM +0200, Erik Hugne wrote:
> > Thanks Eric, it works as expected after applying this.
> 
> So, on to the next problem, now i'm getting corrupted packets
> from the driver instead. Would be great to get some comments
> from the Emulex guys regarding this.
> 
> Attaching a printk trace where i log the mac header and packet data of 
> all 0x88CA (TIPC) packets in the gro_receive routine that have an 
> erroneous TIPC header. This happens immediately when i register 
> myself with the device.
> 


You could check using a GRE tunnel, that the GRO support I added in
recent kernel is working or not. (including the be2net patch I sent)
