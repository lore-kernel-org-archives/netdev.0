From: Vinod Koul <vinod.koul@linux.intel.com>
Subject: Re: [PATCH linux-next] dmaengine: add context
	parameter fixups
Date: Mon, 26 Mar 2012 16:18:26 +0530
Message-ID: <1332758906.19804.97.camel@vkoul-udesk3>
References: <1332511242-30241-1-git-send-email-alexandre.bounine@idt.com>
	<CAOMZO5B-Zutv-xwqLCAgNMO8A3Kyg4uWqS41koo-yoS4mGB1TQ@mail.gmail.com>
	<1332740082.19804.15.camel@vkoul-udesk3>
	<20120326094200.GA3098@opensource.wolfsonmicro.com>
	<1332755670.19804.91.camel@vkoul-udesk3>
	<20120326103354.GD3098@opensource.wolfsonmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: fabio.estevam@freescale.com, alsa-devel@alsa-project.org, samuel@sortiz.org,
	paul.gortmaker@windriver.com, tiwai@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexandre Bounine <alexandre.bounine@idt.com>,
	linux-next@vger.kernel.org, dan.j.williams@intel.com,
	Fabio Estevam <festevam@gmail.com>, lrg@ti.com
To: Mark Brown <broonie@opensource.wolfsonmicro.com>
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20120326103354.GD3098@opensource.wolfsonmicro.com>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-26 at 11:33 +0100, Mark Brown wrote:
> On Mon, Mar 26, 2012 at 03:24:30PM +0530, Vinod Koul wrote:
> 
> > Now either I drop these from 3.4 or merge Linus's tree and apply
> > Alexandre's fix (as that is the right fix rather than one in asoc tree)
> > And since this was required for RIO patches which are still WIP, I think
> > I am leaning towards former.
> 
> Gah, WTF is going on here?  Has this API change not been sent to Linus
> already, and what is wrong with the changes which Fabio sent?  I've
> already applied Fabio's change on the understanding that this API change
> done and dusted.
> 
> It seems better to do a minimal fix at this point rather than churning
> things again...

The change is technically correct, so don't worry it wont break
anything, and API is frozen and not changing.

But we don't want the clients to use this additional parameter or be
exposed to it if not required. Every client is expected to use the
dmaengine wrappers for prepare and not invoke .device_ callbacks.


-- 
~Vinod
