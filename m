From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [2/4] 2.6.22-rc3: known regressions
Date: Tue, 29 May 2007 08:01:45 -0700
Message-ID: <20070529080145.60be9018@freepuppy>
References: <465C188F.9000900@googlemail.com>
	<465C22F4.8080505@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Ruben <nahoo82@terra.es>, linux-pci@atrey.karlin.mff.cuni.cz,
	Greg KH <greg@kroah.com>,
	"Mike Miller (OS Dev)" <mikem@beardog.cca.cpqcorp.net>,
	tom.l.nguyen@intel.com, linux-pcmcia@lists.infradead.org,
	Robert de Rooy <robert.de.rooy@gmail.com>,
	Alan Cox <alan@redhat.com>, Tejun Heo <htejun@gmail.com>,
	linux-ide@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Gregor Jasny <gjasny@googlemail.com>,
	sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mikael Pettersson <mikpe@it.uu.se>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759139AbXE2PKu@vger.kernel.org>
In-Reply-To: <465C22F4.8080505@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 May 2007 14:56:20 +0200
Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:

> Hi all,
> 
> Here is a list of some known regressions in 2.6.22-rc3.
> 
> Feel free to add new regressions/remove fixed etc.
> http://kernelnewbies.org/known_regressions
> 
> 
> 
> Networking
> 
> Subject    : Network card not usable - sky2
> References : http://bugzilla.kernel.org/show_bug.cgi?id=8539
> Submitter  : Ruben <nahoo82@terra.es>
> Status     : Unknown
> 


Not a regression. Read the bug report:
	Most recent kernel where this bug did *NOT* occur:

	It's been happening for a long time (I'd say always).



There is a regression since 2.6.22-rc1 where the b44 driver has
receive performance/interrupt lockup issues.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
