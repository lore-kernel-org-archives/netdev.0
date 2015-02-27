From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] netns: avoid allocating idr when dumping info
Date: Fri, 27 Feb 2015 10:04:15 -0800
Message-ID: <1425060255.5130.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F09A95.8000507@6wind.com>
	 <CAM_iQpUPQVodJRGmf=GYOVK+R_84w-+yDtqyHCJGbCDH0hb44A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:37702 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbbB0SES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 13:04:18 -0500
Received: by iecrl12 with SMTP id rl12so32851616iec.4
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 10:04:17 -0800 (PST)
In-Reply-To: <CAM_iQpUPQVodJRGmf=GYOVK+R_84w-+yDtqyHCJGbCDH0hb44A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 09:28 -0800, Cong Wang wrote:

> I don't understand why you think this is over engineering,
> clearly it is normal to allocate resources in newlink rather than
> dumping. Look at other resources we allocate in newlink.

This has nothing to do with the splat you gave.

If you believe there is a _different_ bug, then submit another patch.

But claiming your patch solves the rcu thing is misleading,
you gave already 2 wrong patches, trying to hide the real fix.
