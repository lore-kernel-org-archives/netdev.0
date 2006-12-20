From: Olivier Galibert <galibert@pobox.com>
Subject: Re: Network drivers that don't suspend on interface down
Date: Wed, 20 Dec 2006 16:27:01 +0100
Message-ID: <20061220152701.GA22928@dspnet.fr.eu.org>
References: <20061219185223.GA13256@srcf.ucam.org> <200612191959.43019.david-b@pacbell.net> <20061220042648.GA19814@srcf.ucam.org> <200612192114.49920.david-b@pacbell.net> <20061220053417.GA29877@suse.de> <20061220055209.GA20483@srcf.ucam.org> <1166601025.3365.1345.camel@laptopd505.fenrus.org> <20061220125314.GA24188@srcf.ucam.org> <1166621931.3365.1384.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Garrett <mjg59@srcf.ucam.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965135AbWLTP1F@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
Content-Disposition: inline
In-Reply-To: <1166621931.3365.1384.camel@laptopd505.fenrus.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 20, 2006 at 02:38:51PM +0100, Arjan van de Ven wrote:
> [1] What kind of latency would be allowed? Would an implementation be
> allowed to power up the phy say once per minute or once per 5 minutes to
> see if there is link? The implementation could do this progressively;
> first poll every X seconds, then after an hour, every minute etc.

I suspect that the hard maximum latency is the time needed by the user
to start the network himself, be it opening a root xterm and doing the
appropriate invocation or pulling up and clicking where appropriate in
a GUI.  That's probably around 5 seconds.  Over that, and they won't
even notice there is an autodetection running.

But still, 5 seconds is probably too much too, because it's going to
look like it's unreliable.  The user has to see something happen
within half-a-second or so, otherwise he's going to start doing it by
hand.  The "see" part is distribution/desktop-dependant and not the
kernel problem, but the top chrono happens when the rj45 is plugged
in.

  OG.
