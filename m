From: Werner Almesberger <wa@almesberger.net>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Sat, 24 May 2003 01:23:50 -0300
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030524012350.A15179@almesberger.net>
References: <Pine.LNX.4.40.0305220107460.29409-100000@phil.home.phil> <3ECC0B14.7020105@ethanet.com> <20030524011148.A29146@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philippe Biondi <biondi@cartel-securite.fr>,
	Jamal Hadi <hadi@shell.cyberus.ca>,
	Martin Josefsson <gandalf@wlug.westbo.se>,
	"David S. Miller" <davem@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Ethan Sommer <sommere@ethanet.com>
Content-Disposition: inline
In-Reply-To: <20030524011148.A29146@almesberger.net>; from wa@almesberger.net on Sat, May 24, 2003 at 01:11:48AM -0300
List-Id: netdev.vger.kernel.org

I wrote:
> Now, how to turn such expressions with embedded ^ efficiently
> into a DFA ?

Well, that's too easy. The DFA should also test bits only in the
order in which they appear in the packet. Constructing a DFA that
jumps back and forth and tests the same bit over and over again
wouldn't be much of a challenge :-)

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
