From: Andi Kleen <ak@suse.de>
Subject: Re: The ultimate TOE design
Date: Thu, 16 Sep 2004 08:20:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916062033.GB12915@wotan.suse.de>
References: <4148991B.9050200@pobox.com> <Pine.NEB.4.33.0409151704200.5383-100000@dexter.psc.edu> <20040915144624.1339fbc5.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Heffner <jheffner@psc.edu>, netdev@oss.sgi.com,
        leonid.grossman@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040915144624.1339fbc5.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 15, 2004 at 02:46:24PM -0700, David S. Miller wrote:
> On Wed, 15 Sep 2004 17:36:18 -0400 (EDT)
> John Heffner <jheffner@psc.edu> wrote:
> 
> > The other (much nicer) solution to case (b) is to just USE A BIGGER MTU.
> > 1500 bytes is ridiculously small.  Even with a 9k MTU, the benefits of TOE
> > or TSO are nearly vanishing.  Those who say they require high performance,
> > but are unwilling to buy or produce networking gear with an MTU larger
> > than 1500 bytes probably deserve what they get.
> 
> TSO gives a kind of virtual 64K MTU, FWIW.  But I do see your
> point.

We still need to solve the same problem for RX though.

-Andi
