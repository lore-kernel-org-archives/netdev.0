From: Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH/RFC] Re: recvmmsg() timeout behavior strangeness [RESEND]
Date: Tue, 27 May 2014 16:21:15 -0300
Message-ID: <20140527192115.GD25474@kernel.org>
References: <536101C9.9090601@gmail.com>
 <CAKgNAkgA_xTfRZhpyVwuACpCY7xMK89e0bK4PuVMG9reNV6Skw@mail.gmail.com>
 <20140512143451.GB13801@kernel.org>
 <20140521210535.GA5414@kernel.org>
 <537E0961.8040005@gmail.com>
 <20140526134647.GB8176@kernel.org>
 <20140526211706.GA25474@kernel.org>
 <5384BEC5.2080607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	=?utf-8?B?T25kxZllaiBCw61sa2E=?= <neleai-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
	Caitlin Bestler <caitlin.bestler-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Elie De Brauwer <eliedebrauwer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Steven Whitehouse <steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>, Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
	Chris Friesen <chris.friesen-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5384BEC5.2080607-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Em Tue, May 27, 2014 at 06:35:17PM +0200, Michael Kerrisk (man-pages) escreveu:
> On 05/26/2014 11:17 PM, Arnaldo Carvalho de Melo wrote:
> > Can you try the attached patch on top of the first one?
 
> Patches on patches is a way to make your testers work unnecessarily
> harder. Also, it means that anyone else who was interested in this

It was meant to highlight the changes with regard to the previous patch,
i.e. to make things easier for reviewing.

> thread likely got lost at this point, because they probably didn't 
> save the first patch. All of this to say: it makes life much easier 
> if you provide a complete new self-contained patch on each iteration.

If you prefer it that way, find one attached, that I was about to send
(but you can wait till I use your program to test it ;-) )
 
> > It starts adding explicit parentheses on a ternary, as David requested,
> > and then should return the remaining timeouts in cases like signals,
> > etc.
> > 
> > Please let me know if this is enough.
> 
> Nope, it doesn't fix the problem. (I applied both patches against 3.15-rc7)

What was the problem experienced?
 
> > P.S. compile testing while sending this message :-)
> 
> Okay -- how about some real testing for the next version ;-). I've appended

Hey, you were provinding that real testing! thanks for that! :-)

> my test program below. You can use it as follows:
> 
> ./t_recvmmsg <port> <timeout-in-secs> <bufsize>...
> 
> (The timeout can also be '-' meaning use NULL as the timeout argument.)

Thanks for the test proggie, will use it.
 
> Cheers,
> 
> Michael
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
