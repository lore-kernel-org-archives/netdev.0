From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: Kill I4L?
Date: Mon, 9 Feb 2015 19:48:13 +0000
Message-ID: <20150209194813.180e54ae@lxorguk.ukuu.org.uk>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
	<1423328797-17865-3-git-send-email-baspeters93@gmail.com>
	<54D650BF.5000400@cogentembedded.com>
	<1423336761.2933.7.camel@perches.com>
	<1423341800.2246.68.camel@x220>
	<54D7BD4A.4090101@imap.cc>
	<54D7F87E.4050506@linux-pingi.de>
	<CAOgR63f702_QTHpnAB-G9-o3DPEuyiESLeNTz4saOTHB4SnBdg@mail.gmail.com>
	<54D891C0.2010303@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bas Peters <baspeters93@gmail.com>,
	Karsten Keil <kkeil@linux-pingi.de>,
	Paul Bolle <pebolle@tiscali.nl>, Joe Perches <joe@perches.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"isdn@linux-pingi.de" <isdn@linux-pingi.de>,
	Julia Lawall <julia.lawall@lip6.fr>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54D891C0.2010303@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The reason is the maintenance load it produces. There's a continuous,
> annoying trickle of patch  proposals, discussions, conflicts with
> development in other, still actively maintained areas of the kernel,
> and so on. The present discussion being a point in case.
> 
> > Does it hurt anyone to leave the code in there, despite it barely 
> > being used?
> 
> Yes it does. Not much, but the pain is increasing over the years.
> Every time someone tries to touch that code there's the problem
> that no one can actually answer for it, much less test anything.

The same has been happening with a lot of other code. For i2o I've
followed the pattern a few other drivers have used. I sent GregKH a patch
to move it into staging, and if nobody steps up then it will vanish in a
few releases.

> > We're not talking about a particularly huge driver here, either.
> 
> But one that's particularly difficult to maintain, without
> providing any noticeable benefit in return.

I'm also not sure a pretty, polished and untested driver is actually
better than someone who needs it going back to an old tree and a known
working driver to forward port.

Alan
