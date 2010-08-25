From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [Bugme-new] [Bug 16821] New: g_ether no carrier while it is
Date: Tue, 24 Aug 2010 23:44:19 -0700
Message-ID: <20100824234419.326ce966.akpm@linux-foundation.org>
References: <20100824164006.0bd7b7e8.akpm@linux-foundation.org>
	<559294.8951.qm@web180302.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	public.avatar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Brian Niebuhr <bniebuhr-JaPwekKOx1yaMJb+Lgu22Q@public.gmane.org>
To: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <559294.8951.qm-g47maUHHHF+ZZBmlwP4mLPu2YVrzzGjVVpNB7YpNyf8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Aug 2010 22:38:39 -0700 (PDT) David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org> wrote:

> 
> 
> --- On Tue, 8/24/10, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> 
> > From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> > Subject: Re: [Bugme-new] [Bug 16821] New: g ether no carrier while it is
> > To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Cc: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org, "Greg KH" <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, "David Brownell" <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>, public.avatar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> > Date: Tuesday, August 24, 2010, 4:40 PM
> > 
> > (switched to email.   Please respond via emailed
> > reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Mon, 23 Aug 2010 06:24:16 GMT
> > bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
> > wrote:
> > 
> > > https://bugzilla.kernel.org/show bug.cgi?id=16821
> > > 
> > >                  Summary:
> > g ether no carrier while it is
> > >                  Product:
> > Networking
> > >                  Version: 2.5
> > >         Kernel Version: 2.6.3(2 - ok,
> > 3?, 4-6 - fail)
> > >                  Platform:
> > All
> > >               OS/Version:
> > Linux
> > >                 
> >       Tree: Mainline
> > >              
> >       Status: NEW
> > >                  Severity:
> > blocking
> > >                  Priority:
> > P1
> > >               Component: Other
> > >               AssignedTo: acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org
> > >               ReportedBy: public.avatar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
> > >               Regression: Yes
> > > 
> > > 
> > > After successfully loaded g ether module (with
> > use eem=0) usb device appears.
> > > If I configure it at host as ifconfig usb0 blah bah,
> > than network present, all
> > > ok. 
> > > In windows (with RNDIS config), and in linux with
> > bridge it looks to CARRIER
> > > state. I get in ip addr state DOWN, NO-CARRIER. That's
> > why g ether usb device
> > > in bridge and windows don't work at all.
> > 
> > So g ether broke after 2.6.32?
> > 
> > Nobody really seems to do much with that USB driver.
> 
> That's changed then.  There used to be boxes that
> relied on it for their network connectivity...

I meant not much development happens there.

> Adding EEM support was something... I think the
> issue might be driver changes since last it was
> seriously tested in bridge configs (for which
> the link state, such as carrier, matters LOTS.)

Thanks.  Let's cc Brian.

> 
> > I wonder if some
> > changes in core networking could have triggered this?
> 
> Wouldn't be my first thought; but might be.
> 
> ISTR getting link/carrier state to behave in
> the first place (with just CDC and RNDIS) was
> complex.  If it wasn't carefully re-tested after
> EEM was added, breakage may have been overlooked.
> 
> - Dave
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
