From: Zheng Liu <gnehzuil.liu@gmail.com>
Subject: Re: What's the status of TCP friends?
Date: Mon, 17 Mar 2014 11:16:05 +0800
Message-ID: <20140317031605.GA22502@gmail.com>
References: <20140316090744.GA14572@gmail.com>
 <1394978619.9668.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Li Yu <bingtian.ly@taobao.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Brutus Curtis <brutus@google.com>,
	Weiping Pan <panweiping3@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:52624 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068AbaCQDKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 23:10:19 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so5150087pab.10
        for <netdev@vger.kernel.org>; Sun, 16 Mar 2014 20:10:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1394978619.9668.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 16, 2014 at 07:03:39AM -0700, Eric Dumazet wrote:
> On Sun, 2014-03-16 at 17:07 +0800, Zheng Liu wrote:
> > Hi all,
> > 
> > Until now the TCP friends patch set doesn't be applied.  Now what's the
> > status of TCP friends?  Is it applicable to be merged into upstream
> > kernel?  Any problem that needs to be fixed?  Please let me know if I
> > can help.
> 
> Well, last attempts showed that while the idea sounded cool,
> implementation opened many races and added quite a lot of complexity in
> fast path.

Thanks for letting me know the current status of this patch set.

> 
> We have AF_UNIX with a lot of problems in it, do we really want to bring
> these AF_UNIX problems to AF_INET ?

Please bear with me because I am a newbie.  Out of curiosity, what's the
problem in AF_UNIX?

> 
> I would rather spend time on AF_UNIX if it doesn't fit your needs right
> now, or consider jumping to KDBUS modern design.
> 
> Using AF_INET for IPC is poor choice.

The reason why we use AF_INET for IPC rather than use AF_UNIX is that we
have two applications that need to communicate with each other.  They
could be deployed on the same server or different servers.  So obviously
if we use AF_INET, we just need to indicate a IP address in config file.
That sounds rational and maintainable for our operation team.

Regards,
                                                - Zheng
