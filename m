From: CaT <cat@zip.com.au>
Subject: Re: strange network slowness in 2.6 unless pingflooding
Date: Tue, 28 Sep 2004 08:49:57 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040927224957.GA1043@zip.com.au>
References: <20040927090342.GA1794@zip.com.au> <41587A26.6020606@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	jgarzik@pobox.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Content-Disposition: inline
In-Reply-To: <41587A26.6020606@conectiva.com.br>
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 05:37:58PM -0300, Arnaldo Carvalho de Melo wrote:
> CaT wrote:
> >Hi,
> >
> >This is still happening. I ran the same set of tests on a totally
> >different network, with my xircom  realport ethernet card (tulip
> >driver - 16bit) and from linux to linux and windows to linux. Scrolling
> >through a message in mutt eventually slows down and if I lift my finger
> >off the enter key whilst it's slow the scrolling keeps going, as if it
> >was all bufferd. If I do a pingflood (ping -f) from a machine to my
> >laptop it's all fine.
> >
> >I am also now running 2.6.9-rc1-mm4.
> 
> Have you tried FAQ:
> 
> echo 0 > /proc/sys/net/ipv4/tcp_window_scaling

It does not help. Same problem as before.

-- 
    Red herrings strewn hither and yon.
