From: Jeff Garzik <jgarzik@pobox.com>
Subject: wireless geo stuff (was Re: wireless-2.6 status (25 January 2006))
Date: Thu, 26 Jan 2006 21:15:53 -0500
Message-ID: <43D98259.8090406@pobox.com>
References: <C86180A8C204554D8A3323D8F6B0A29FEB471D@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mbuesch@freenet.de>,
	Ben Greear <greearb@candelatech.com>,
	David Hollis <dhollis@davehollis.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Samuel Ortiz <samuel.ortiz@nokia.com>, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030255AbWA0CQM@vger.kernel.org>
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29FEB471D@dhost002-46.dex002.intermedia.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Barber wrote:
> In order to get FCC certification the manufacturer must ensure there is
> no easy way for the user to tune to illegal frequencies. Broadcom has
> done their job - it was not easy to reverse engineer their driver. Now
> the cat is out of the bag. The open source driver is not illegal -
> although it may be illegal to use it - since the chipset and driver were
> likely certified together. I'm no expert in FCC regulation, so take all
> of this with a pinch of salt.

First, kernel developers should do the best they can to provide 
facilities to limit the frequencies, including sane and safe defaults 
for the softmac cases.  It just makes sense to do that, from a "friendly 
neighbor" and "don't operate out of spec" perspective, if nothing else. 
  It's damned _rude_ to use channels other than the ones selected by the 
Responsible Authority.  Some ham radio operator -- like me -- might be 
using that frequency to carry on a pleasant Morse code conversation with 
someone else halfway across the world.  Linux software shalt not be 
rude.  :)

Second, if someone takes steps to disable these safeguards we build in, 
that's akin to putting illegal crystals into a radio, or tuning a 
transmitter to police/emergency bands.

Finally, binary-only software is clearly _not_ a barrier to this sort of 
circumvention.  Reverse engineering x86 software is a skill that's very 
widespread, relative to other sorts of reverse engineering.  Reverse 
engineering tools for the x86 are very mature these days, having had two 
decades to grow and flourish.  If the _hardware_ can be programmed 
maliciously, there's not a whole lot you can do about it... particularly 
when the hardware manufacturer chooses a method of obfuscation (x86 
code) practically designed for easy analysis.

	Jeff
