From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 27 Jul 2003 17:14:03 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030727171403.6e5bcc58.davem@redhat.com>
References: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
	<200307280140470646.1078EC67@192.168.128.16>
	<20030727164649.517b2b88.davem@redhat.com>
	<200307280158250677.10891156@192.168.128.16>
	<20030727165831.05904792.davem@redhat.com>
	<200307280211590888.10957DD9@192.168.128.16>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Carlos Velasco" <carlosev@newipnet.com>
In-Reply-To: <200307280211590888.10957DD9@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[ Please wrap your lines at 72 characters, you emails are really
  difficult to read and reply to, thanks. ]

On Mon, 28 Jul 2003 02:11:59 +0200
"Carlos Velasco" <carlosev@newipnet.com> wrote:

> On 27/07/2003 at 16:58 David S. Miller wrote:
> >His problem is about source address selection when trying to
> >contact a given destination.
> 
> Bas said:
> ==
> >but it turned out that this wasn't the case. On closer examination it
> >turned out that any ARP request to a local IP resulted in a response,
> >even if the devices were on different subnets or ethernet segments.
> ==
> 
> It's the "hidden" switch.... again.
> I suppose that Bas can confirm it.

This only means your problem can also be fixed by correcting
your routing tables.

> >It's totally illogical to say that it's easier for him to patch his
> >kernel and reboot it than fix his route configuration.
> 
> Sure... it WOULD be the easiest thing if it would be into the kernel
> >main stream. But it isn't, making linux behave different to other
> >OS and systems without any way or feature to make it behave like
> >the others.

Show me the standard that Linux violates by behaving in this way?
There are none, our behavior is perfectly acceptable.

Other systems do not give you the capabilities our routing layer does,
such as route based source address selections.  So it is no surprise
that they behave differently in this area.
