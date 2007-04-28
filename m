From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [stable] 2.6.21 known regressions (v2) (for -stable team)
Date: Sat, 28 Apr 2007 23:21:54 +0200
Message-ID: <m3647gchzh.fsf@maximus.localdomain>
References: <463375E5.5040108@googlemail.com>
	<200704281252.20381.gene.heskett@gmail.com>
	<20070428181933.GA9811@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gene Heskett <gene.heskett@gmail.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Jeff Mahoney <jeffm@suse.com>,
	Vincent Frentzel <zcecc22@ucl.ac.uk>,
	Riccardo Ricci <rricci@nuovanetmore.it>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Brownell <david-b@pacbell.net>,
	Giorgio Lando <patroclo7@gmail.com>,
	Jeff Chua <jeff.chua.linux@gmail.com>,
	H??kan Lindqvist <lindqvist@netstar.se>,
	Fran??ois Valenduc <francois.valenduc@skynet.be>,
	"Udo A. Steinberg" <us15@os.inf.tu-dresden.de>,
	linux-acpi@vger.kernel.org, Thomas Meyer <thomas.mey@web.de>,
	stable@kernel.org, Len Brown <len.brown@intel.com>,
	Dave Jones <davej@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Francois SIMOND <curio@free.fr>,
	Andrew Morton <akpm@lin
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55529 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753641AbXD1VV5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 17:21:57 -0400
In-Reply-To: <20070428181933.GA9811@kroah.com> (Greg KH's message of "Sat, 28 Apr 2007 11:19:33 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH <greg@kroah.com> writes:

>> Also, assignation of ttyUSB#'s is volatile depending on phase of the
>> moon when booted.
>
> That's always been the case, ever since the 2.2 kernel releases.  Please
> use udev if you want persistent device names for your tty USB devices.

I don't know how udev (or anything) could help here. AFAIK the
converters have no serial numbers and no other means to
differentiate.
-- 
Krzysztof Halasa
