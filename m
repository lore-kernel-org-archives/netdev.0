From: Lance Lassetter <lancelassetter@gmail.com>
Subject: Re: r8169 with 3.9.0-rc9
Date: Fri, 17 May 2013 09:35:48 -0500
Message-ID: <20130517143546.GA527@gmail.com>
References: <20130428011232.GA4236@gmail.com>
 <20130501100733.GA16115@gmail.com>
 <20130501121502.GA5456@electric-eye.fr.zoreil.com>
 <20130501212803.GA3342@gmail.com>
 <20130501223155.GA15261@electric-eye.fr.zoreil.com>
 <20130502021848.GA30099@gmail.com>
 <20130502221837.GA9898@electric-eye.fr.zoreil.com>
 <20130505151732.GA9096@gmail.com>
 <20130505193323.GA21121@electric-eye.fr.zoreil.com>
 <20130514030432.GA18292@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f170.google.com ([209.85.161.170]:50145 "EHLO
	mail-gg0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754321Ab3EQOfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 10:35:53 -0400
Received: by mail-gg0-f170.google.com with SMTP id s5so889996ggc.1
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 07:35:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130514030432.GA18292@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 13, 2013 at 10:04:34PM -0500, Lance Lassetter wrote:
> On Sun, May 05, 2013 at 09:33:23PM +0200, Francois Romieu wrote:
> > Lance Lassetter <lancelassetter@gmail.com> :
> > [...]
> > > What do you think, Ueimor ?
> > 
> > I think you should try a post 3.9 kernel including commit
> > 4ada8db38a44654446fe35ceb20a1972220e0f69 ("net: Restore NETIF_F_* bit
> > ordering.").
> > 
> > -- 
> > Ueimor
> 
> Ueimor,
> 
> Tried stock 3.10-rc1.  Still same problem with alias r8169 alias p10p1 and p8p1 "up down, up down".
> 
> Does this kernel inclde your patch?  I think it does....
> 
> Please reply with suggestions.
> 
> Regards,
> 
> Lance Lassetter

Ueimor,

I don't think it's a driver problem as I've tried three separate drivers all to the same effect:  link up/link down.

I think it might be Fedora faulty power management orba udev problem.  I've modified /etc/udev/70-persisetent-net.rules, let's see what happens.

Thanks,

Lance
