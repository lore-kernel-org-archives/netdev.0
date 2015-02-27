From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] netns: avoid allocating idr when dumping info
Date: Fri, 27 Feb 2015 08:55:58 -0800
Message-ID: <1425056158.5130.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F09A95.8000507@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:42519 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbbB0Q4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 11:56:00 -0500
Received: by igkb16 with SMTP id b16so1888853igk.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 08:56:00 -0800 (PST)
In-Reply-To: <54F09A95.8000507@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 17:25 +0100, Nicolas Dichtel wrote:

> That's true. The patch does not cover the following case:
> ip link add foo type bar
> ip link set foo netns netns1
> 
> In this case, the second command will call dev_change_net_namespace() and the
> id will not be allocated.
> 
> I think Eric's patch is simpler and less error-prone.
> 
> FWIW, I will be off for one week and probably without any internet access ;-)

I am cooking an official patch right now, thanks !
