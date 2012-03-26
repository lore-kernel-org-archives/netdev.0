From: Vinod Koul <vinod.koul@linux.intel.com>
Subject: Re: [PATCH linux-next] dmaengine: add context parameter fixups
Date: Mon, 26 Mar 2012 15:24:30 +0530
Message-ID: <1332755670.19804.91.camel@vkoul-udesk3>
References: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
	 <CAOMZO5B-Zutv-xwqLCAgNMO8A3Kyg4uWqS41koo-yoS4mGB1TQ@mail.gmail.com>
	 <1332740082.19804.15.camel@vkoul-udesk3>
	 <20120326094200.GA3098@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <festevam@gmail.com>,
	Alexandre Bounine <alexandre.bounine@idt.com>,
	paul.gortmaker@windriver.com, dan.j.williams@intel.com,
	samuel@sortiz.org, lrg@ti.com, perex@perex.cz, tiwai@suse.de,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, fabio.estevam@freescale.com,
	alsa-devel@alsa-project.org
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120326094200.GA3098@opensource.wolfsonmicro.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-26 at 10:42 +0100, Mark Brown wrote:
> On Mon, Mar 26, 2012 at 11:04:42AM +0530, Vinod Koul wrote:
> > On Sat, 2012-03-24 at 12:23 -0300, Fabio Estevam wrote:
> 
> > > http://permalink.gmane.org/gmane.linux.alsa.devel/96215
> 
> > And this seems to be linux-next.
> 
> > Mark, Is this part of the sound updates that went to Linus?
> 
> No, not yet - it was only sent after the merge window.  Quite why nobody
> managed to notice it before then I don't know.  It'll go to him soon, or
> at least to Takashi, but don't know if it'll make -rc1 or not.
I should have noticed that sound needs update as well  :(

Now either I drop these from 3.4 or merge Linus's tree and apply
Alexandre's fix (as that is the right fix rather than one in asoc tree)
And since this was required for RIO patches which are still WIP, I think
I am leaning towards former.

-- 
~Vinod
