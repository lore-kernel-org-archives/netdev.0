From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: Link detection
Date: Mon, 14 Mar 2005 20:41:21 +0200
Message-ID: <200503142041.21451.hasso@estpak.ee>
References: <200503141435.38227.hasso@estpak.ee> <200503141605.02959.hasso@estpak.ee> <20050314145710.GO31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050314145710.GO31837@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Hasso Tepper <200503141605.02959.hasso@estpak.ee> 2005-03-14 16:05
> > I think that you misunderstood. I don't talk about any routes created
> > by any user space applications or by user. These _must_ be untouched of
> > course. I'm talking about routes _kernel_ creates if address is added
> > to the interface. All other routes are not problem anyway. Even if
> > their next hop points to network behind down interface, their next hop
> > is unreachable and route shouldn't be used, no?
>
> Makes a lot more sense now. Yes, the nexthops should be marked
> unreachable since the routing cache flushed upon a NETDEV_CHANGE.
>
> What about setting RFT_REJECT/RTN_UNREACHABLE on those routes for the
> time the carrier is gone?

>From users' point of view I think that any solution is acceptable which 
prevents kernel to actually use these routers if carrier is down. And 
setting flags might be less expensive of course.


with my best wishes,

-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
