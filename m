From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [patch 3/3] Add netpoll/netconsole support to vlan devices
Date: Tue, 26 Sep 2006 10:15:27 +0200
Message-ID: <9a8748490609260115v6743fd90w59d75cf1de8d8a3c@mail.gmail.com>
References: <200609252343.k8PNhAKO002851@shell0.pdx.osdl.net>
	 <20060925.223436.08322700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, davem@redhat.com,
	greearb@candelatech.com, mingo@redhat.com, mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:26439 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1750792AbWIZIP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 04:15:28 -0400
Received: by wx-out-0506.google.com with SMTP id s14so2113837wxc
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 01:15:28 -0700 (PDT)
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060925.223436.08322700.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26/09/06, David Miller <davem@davemloft.net> wrote:
> From: akpm@osdl.org
> Date: Mon, 25 Sep 2006 16:43:10 -0700
>
> > +#ifdef CONFIG_NET_POLL_CONTROLLER
> > +     new_dev->poll_controller = real_dev->poll_controller;
> > +#endif
> > +
>
> I don't see how this part can be correct.  If netpoll actually
> calls new_dev->poll_controller it will pass new_dev in
> (ie. the VLAN device) yet this method is for real_dev.
>
> If the only side effect of this assignment is that netpoll recognizes
> the device as being usable with netpoll, that's really a nasty way to
> accomplish that.
>
It was the only way I could find to accomplish that. If you know of a
better way I'd appreciate a hint :)

> In any event, propagating this method pointer to the wrong device
> structure is a bug.
>
Ok, then the patch as it stands is dead. I'll try to find another way.
Thank you for your comments.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
