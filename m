From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Sun, 24 Oct 2004 17:22:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5cac192f04102408224ffa9c61@mail.gmail.com>
References: <20041007214505.GB31558@wotan.suse.de>
	 <20041011163601.GM31237@waste.org>
	 <20041011164315.GH26350@wotan.suse.de>
	 <20041011165851.GN31237@waste.org>
	 <20041011224542.5bdc93aa@jack.colino.net>
	 <5cac192f0410181443303379e2@mail.gmail.com>
	 <5cac192f041018145824acce5a@mail.gmail.com>
	 <20041020161119.6e30efe5@pirandello>
	 <5cac192f0410200848179ccc81@mail.gmail.com>
	 <20041021183610.23c5121c.colin@colino.net>
Reply-To: Eric Lemoine <eric.lemoine@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Colin Leroy <colin@colino.net>
In-Reply-To: <20041021183610.23c5121c.colin@colino.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > > > > > [deadlock with sungem & netconsole when no carrier]
> > > > > Sorry I'm catching up on that problem... Do you have your
> > > > > problem solved? If not, did you try removing all printk calls
> > > > > from within gem_poll(), as suggested by Matt Mackall?
> > > >
> > Ok. Keep me posted. If removing the printk's indeed helps I'll cook up
> > a proper fix.
> 
> Ok, it tried... It doesn't help. I tried the wild way too:
> 
>         #define printk(...) do {} while (0);
> 
> It didn't help either. I'll give a look to other net drivers, to see if
> they do stuff differently, but I fear that I won't find it easily...

Thanks for running this Colin. Unfortunately I can't figure out what's
going on at this point.

-- 
Eric
