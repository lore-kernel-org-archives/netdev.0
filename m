From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: Open hardware wireless cards
Date: Wed, 5 Jan 2005 16:35:10 -0500
Message-ID: <20050105213510.GP28140@csclub.uwaterloo.ca>
References: <20050105192447.GJ5159@ruslug.rutgers.edu> <20050105200526.GL5159@ruslug.rutgers.edu> <20050105201434.GB30311@csclub.uwaterloo.ca> <Pine.LNX.4.61.0501051533470.12237@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: prism54-devel@prism54.org, prism54-users@prism54.org,
        Netdev <netdev@oss.sgi.com>, linux-kernel@vger.kernel.org,
        Jeff Garzik <jgarzik@pobox.com>,
        Jean Tourrilhes <jt@bougret.hpl.hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-os@analogic.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0501051533470.12237@chaos.analogic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jan 05, 2005 at 03:48:46PM -0500, linux-os wrote:
> Well its mostly about making boards just a bit too cheap.
> 
> If the vendors would just put in a serial EPROM that loads the
> proprietary stuff to their PLD upon startup, then there is
> no "proprietary" code to worry about. You have the generic
> published interface like a PLX chip, plus the specific published
> register functions of their PLD chip. How the device actually
> makes smoke and mirrors is hidden even from the programmer.
> 
> But, by eliminating the US$0.50 cost of a EPROM, they want to supply
> a sack of bits that needs to be uploaded to the PLD by software. This
> sack of bits can be reverse-engineered so companies are not going
> to supply these (you can extract those bits from a Win-Modem dll so
> this gets a bit too ridiculous for some devices).
> 
> In most cases it's not some algorithm that needs to be protected.
> Instead its the 400-or-so engineering man-hours used to develop the
> contents of the PLD (notice I did not use the words "Gate-Arrays"
> until now. There are many kinds of Programmable Logic Devices).
> 
> Until vendors stop being penny-wise-pound-foolish, we will continue
> to have these kinds of problems. Vendor education will ultimately
> be the fix, I predict.

Well unfortunately I think you underestimate the cost of the serial
eprom needed to do the load on an fpga or pld or the like.  According to
our suppliers they are actually rather hard to get for some reason (that
I don't understand) and are more than $0.50.  The product I am current
working on software for would be a whole lot simpler if we could just
program an eprom with the fpga code, but instead we have to load it via
jtag through the parallel port to save a fair bit of moeny on eprom
chips assuming we could even get them in the quantities we would need.

The winmodem is just a sound card with the cpu doing the actual
algorihtm.  That is different and would not be solved with an eprom,
only with a real DSP or other chip capable of doing the modulation and
demodulation of the signals.  I guess calling them modem's is being too
generous, more like phone line sampler cards.

Len Sorensen
