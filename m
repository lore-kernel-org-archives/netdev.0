From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Repeatable IPv6 crash in 3.19.0-1
Date: Fri, 27 Feb 2015 18:21:06 -0800
Message-ID: <1425090066.5130.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54F0E38C.5060203@vultr.com>
	 <1425084533.5130.54.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425086169.5130.57.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F11FC8.7010100@vultr.com>
	 <1425088894.5130.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425089025.5130.61.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F123C4.2030907@vultr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian Rak <brak@vultr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:45333 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831AbbB1CVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 21:21:08 -0500
Received: by igjz20 with SMTP id z20so5178104igj.4
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 18:21:07 -0800 (PST)
In-Reply-To: <54F123C4.2030907@vultr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 21:11 -0500, Brian Rak wrote:

> We've only recently started using this veth/macvtap combo, so it's 
> possible this has been around for awhile and we just hadn't noticed.
> 
> I don't have any info on older kernels currently.  I *think* I've seen 
> crashes on 3.17.1, but I didn't save any stack traces, so I can't be sure.
> 
> CONFIG_DEBUG_PAGEALLOC is not set, and never has been.

OK, thanks for the confirmation. I'll send an official patch.

(I guess same patch is also needed for drivers/net/tun.c)
