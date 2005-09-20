From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: TCP throttling
Date: Tue, 20 Sep 2005 01:44:40 -0300
Message-ID: <39e6f6c705091921441424a1fb@mail.gmail.com>
References: <200509190646.57579.a1426z@gawab.com>
	 <20050919112008.17ad14f5@dxpl.pdx.osdl.net>
	 <200509200654.23703.a1426z@gawab.com>
Reply-To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@osdl.org>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Al Boldi <a1426z@gawab.com>
In-Reply-To: <200509200654.23703.a1426z@gawab.com>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/20/05, Al Boldi <a1426z@gawab.com> wrote:
> Stephen Hemminger wrote:
> > You probably need to increase the maximum socket buffer
> > sizes.  Linux defaults are conservative to avoid running
> > servers out of memory.
> >
> > http://www.psc.edu/networking/projects/tcptune/#Linux
> 
> Thanks for the great link! It kept me up all night.
> 
> I managed to crash the server running out of memory.  Don't ask what numbers
> I used, I just went overboard.  I played with these numbers before, but
> never imagined that their scale would be in the millions.
> 
> Could you suggest sane values for 2.4/2.6 on a 100mbit link?

Well, perhaps the sane, conservative values are the one already calculated
by the kernel? Just add more memory to your machine and the sane values will
go up accordingly? :-)

- Arnaldo
