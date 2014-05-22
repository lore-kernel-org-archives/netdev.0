From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bonding with tun-devices
Date: Thu, 22 May 2014 07:32:33 -0700
Message-ID: <1400769153.5367.160.camel@edumazet-glaptop2.roam.corp.google.com>
References: <537CB13A.3030100@markas-al-nour.org>
	 <20140521155434.GC6295@redhat.com> <537D0E52.9030901@markas-al-nour.org>
	 <20140522132436.GD6295@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Gasser <list@markas-al-nour.org>, netdev@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:46438 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbaEVOcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 10:32:36 -0400
Received: by mail-pd0-f177.google.com with SMTP id g10so2516078pdj.22
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 07:32:35 -0700 (PDT)
In-Reply-To: <20140522132436.GD6295@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-22 at 15:24 +0200, Veaceslav Falico wrote:

> No worries, I figured it out why it's misbehaving. Basically now bonding
> expects every slave to have support of setting the mac address (that's in
> short), but tun device is a IP device, which doesn't support mac addresses.
> 
> A workaround would be to use tap devices, as they're more "real" and
> support mac address setting.
> 
> I'll, though, try to figure out how to make bonding work even on NOARP
> devices if it doesn't need to fiddle with OSI level 2...

Yes, it sounds some regression was added at some point.

It shouldnt be difficult to fix this.
 
