From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: Stop using tasklets for bottom halves
Date: Tue, 08 Sep 2009 12:40:23 -0400
Message-ID: <1252428023.15626.30.camel@gandalf.stny.rr.com>
References: <43e72e890909071558s637b45c7i10807587dc40e8c4@mail.gmail.com>
	 <20090907171406.6a4b6116@nehalam>
	 <1252376254.21261.2052.camel@gandalf.stny.rr.com>
	 <20090908091143.1e613963@nehalam>
Reply-To: rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matt Smith <Matt.Smith-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Kevin Hayes <kevin-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Bob Copeland <me-aXfl/3sk2vNUbtYUoyoikg@public.gmane.org>, Jouni Malinen <j@w1.fi>,
	Ivan Seskar <Seskar-NvJAj8134tRxEa0u/P/EHDe48wsgrGvP@public.gmane.org>, ic.felix-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090908091143.1e613963@nehalam>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-09-08 at 09:11 -0700, Stephen Hemminger wrote:

> > > Process context is too slow.
> > 
> > Well, I'm hoping to prove the opposite. I'm working on some stuff that I
> > plan to present at Linux Plumbers. I've been too distracted by other
> > things, but hopefully I'll have some good numbers to present by then.
> > 
> 
> 
> That's great, does it keep the good properties of NAPI (irq disabling
> and throttling?)

Not exactly sure what you mean by throttling, but I'm assuming it will.

As for irqs disabling, I'm trying to avoid doing that. Note, the device
will have its interrupts disabled, but not all other devices will.

-- Steve


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
