From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: Unable to halt or reboot due to - unregister_netdevice: waiting for eth0.20 to become free. Usage count = 1
Date: Fri, 1 Sep 2006 13:35:20 +0200
Message-ID: <9a8748490609010435k6b327237ve6a23ddcaa0f4065@mail.gmail.com>
References: <9a8748490609010259l7c42ca88tbcc87410a770b48c@mail.gmail.com>
	 <E1GJ6St-0004Te-00@gondolin.me.apana.org.au>
	 <9a8748490609010351kd8f0d40ud3509e2f3eaa89ac@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, linux-kernel@vger.kernel.org,
	waltje@uwalt.nl.mugnet.org, ross.biro@gmail.com,
	davem@davemloft.net, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:15410 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751485AbWIALf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 07:35:27 -0400
Received: by wx-out-0506.google.com with SMTP id s14so969207wxc
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2006 04:35:26 -0700 (PDT)
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <9a8748490609010351kd8f0d40ud3509e2f3eaa89ac@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/06, Jesper Juhl <jesper.juhl@gmail.com> wrote:
> On 01/09/06, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > Jesper Juhl <jesper.juhl@gmail.com> wrote:
> > >
> > > I've just encountered the problem on a different server with an
> > > identical vlan setup. That server is running 2.6.13.4
> >
> > Do you have a simple recipe to reproduce this? Ideally it'd be a
> > script that anyone can execute in a freshly booted system that
> > exhibits the problem.
> >
> Well, the first server I saw this on only had a base install of debian
> stable on it, then I replaced the kernel, configured the vlan
> interface in /etc/network/interfaces typed 'reboot' and it failed -
> and it seems to fail reliably on reboot every time.
>
Ok, I've done some more testing and it seems, unfortunately, that I
can't trigger the problem reliably. I guess I was just "lucky" with my
first few reboots.
It now seems that uptime and/or amount of data that has flowed over
the vlan interface impacts the probability of hitting the problem.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html
