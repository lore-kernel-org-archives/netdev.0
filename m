From: Marc Dietrich <marvin24@gmx.de>
Subject: Re: [PATCH 1/4] net: rfkill: gpio: remove unused andobsoleteplatform parameters
Date: Mon, 24 Feb 2014 09:42:45 +0100
Message-ID: <4057734.U46kShqM8i@fb07-iapwap2>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com> <2556368.zbgmUK7WzX@ax5200p> <20140224083820.GA15512@xps8300>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Chen-Yu Tsai <wens@csie.org>,
	Rhyland Klein <rklein@nvidia.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140224083820.GA15512@xps8300>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Am Montag, 24. Februar 2014, 10:38:20 schrieb Heikki Krogerus:
> On Sat, Feb 22, 2014 at 11:32:04PM +0100, Marc Dietrich wrote:
> > On Friday 21 February 2014 16:23:49 Heikki Krogerus wrote:
> > > On Fri, Feb 21, 2014 at 02:55:14PM +0100, Marc Dietrich wrote:
> > > > arch/arm/mach-tegra/board-paz00.c is still using platform data. Is
> > > > there
> > > > some prerequisite patch I'm missing (3.14-rc3) or how can this file be
> > > > converted? We are waiting for DT support to arrive so we can finally
> > > > remove this file.
> > > 
> > > True! It still set's the shutdown_gpio and reset_gpio members. I think
> > > I'll leave the header untouched and just clean net/rfkill/rfkill-gpio.c
> > > in this patch. We can remove the whole header after you guys have moved
> > > to DT.
> > 
> > Why? Just update the board file to remove those entries. I just checked
> > that it's working fine without. So if you don't mind, add a patch to
> > remove the entries as the first patch in your series.
> 
> I was hoping I wouldn't have to touch arch/arm/mach-tegra/board-paz00.c
> any more. But OK, I'll add a patch and remove the entries.

hey, someone has to do it :-) I wouldn't mind to do it myself, but you are 
trying to break it, so I think it's your reponsibility to fix it.

Marc
