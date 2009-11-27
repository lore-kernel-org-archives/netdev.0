From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Fri, 27 Nov 2009 23:42:06 +0100
Message-ID: <20091127224206.GA3350@ami.dom.local>
References: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com>
 <20091124111946.GA7883@ff.dom.local>
 <81bfc67a0911250606k1ec76354n217da9ca20b3517c@mail.gmail.com>
 <20091125191105.GA3167@ami.dom.local>
 <81bfc67a0911271007o1fb8f8c2vdd36e8585280e4da@mail.gmail.com>
 <20091127213640.GA2611@ami.dom.local>
 <81bfc67a0911271435g4106652bpe8c9ea07893d0ebd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753701AbZK0Wme@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <81bfc67a0911271435g4106652bpe8c9ea07893d0ebd@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 27, 2009 at 05:35:34PM -0500, Caleb Cushing wrote:
> > I doubt bisecting is a good idea with so unpredictable bug. First, you
> > should make sure it's not a hardware problem, so go back to the kernel
> > you trust most, and give it a really long try with a few recompilations
> > after slightly changing the config. Btw, I wonder if you tried e1000e
> > module parameters like IntMode=0 or 1.
> 
> no, how do I set those?

modprobe -r e1000e
modprobe e1000e IntMode=0

Jarek P.
