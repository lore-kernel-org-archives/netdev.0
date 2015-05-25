From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 15:38:21 -0700
Message-ID: <1432593501.4060.193.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
	 <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432579766.32671.66.camel@jasiiieee.pacifera.com>
	 <1432580733.4060.178.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432581685.32671.80.camel@jasiiieee.pacifera.com>
	 <1432586494.4060.183.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1432589642.32671.108.camel@jasiiieee.pacifera.com>
	 <1432592520.32671.110.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33022 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbbEYWiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 18:38:23 -0400
Received: by padbw4 with SMTP id bw4so78162651pad.0
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 15:38:22 -0700 (PDT)
In-Reply-To: <1432592520.32671.110.camel@jasiiieee.pacifera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 18:22 -0400, John A. Sullivan III wrote:

> 2) Why do we still not negotiate the 16MB buffer that we get when we are
> not using GRE?

What exact NIC handles receive side ?

If drivers allocate a full 4KB page to hold each frame,
plus sk_buff overhead,
then 32MB of kernel memory translates to 8MB of TCP window space.
