From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Date: Thu, 18 Jun 2015 23:21:00 -0400
Message-ID: <20150618232100.78318096@gandalf.local.home>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
	<20150617230819.0a11e47a@grimm.local.home>
	<CAHQdGtQfF8sgfj6B2H=Sg+mn6ghPD+4UuZMSMFjj3XCVee60pw@mail.gmail.com>
	<20150618154914.57424225@gandalf.local.home>
	<20150618185051.2b2828c3@tlielax.poochiereds.net>
	<20150618210843.4b09c31c@grimm.local.home>
	<20150618213702.33f64b20@synchrony.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Linux NFS Mailing List <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Network Devel Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org
To: Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150618213702.33f64b20-08S845evdOaAjSkqwZiSMmfYqLom42DlXqFh9Ls21Oc@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Jun 2015 21:37:02 -0400
Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org> wrote:

> > Note, the box has been rebooted since I posted my last trace.
> > 
> 
> Ahh pity. The port has probably changed...if you trace it again maybe
> try to figure out what it's talking to before rebooting the server?

I could probably re-enable the trace again.

Would it be best if I put back the commits and run it with the buggy
kernel. I could then run these commands after the bug happens and/or
before the port goes away.

 
> Oh! I was thinking that you were seeing this extra port on the
> _client_, but now rereading your original mail I see that it's
> appearing up on the NFS server. Is that correct?

Correct, the bug is on the NFS server, not the client. The client is
already up and running, and had the filesystem mounted when the server
rebooted. I take it that this happened when the client tried to
reconnect.

Just let me know what you would like to do. As this is my main
production server of my local network, I would only be able to do this
a few times. Let me know all the commands and tracing you would like to
have. I'll try it tomorrow (going to bed now).

-- Steve


> 
> So, assuming that this is NFSv4.0, then this port is probably bound
> when the server is establishing the callback channel to the client. So
> we may need to look at how those xprts are being created and whether
> there are differences from a standard client xprt.
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
