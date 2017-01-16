From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: marvell: skge: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 16 Jan 2017 09:50:03 -0800
Message-ID: <20170116095003.6998b773@xeon-e3>
References: <1484395708-4107-1-git-send-email-tremyfr@gmail.com>
        <20170116092951.3b577463@xeon-e3>
        <20170116.123617.1891198374111644473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tremyfr@gmail.com, mlindner@marvell.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170116.123617.1891198374111644473.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Jan 2017 12:36:17 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Mon, 16 Jan 2017 09:29:51 -0800
> 
> > On Sat, 14 Jan 2017 13:08:28 +0100
> > Philippe Reynes <tremyfr@gmail.com> wrote:
> >   
> >> The ethtool api {get|set}_settings is deprecated.
> >> We move this driver to new api {get|set}_link_ksettings.
> >> 
> >> The callback set_link_ksettings no longer update the value
> >> of advertising, as the struct ethtool_link_ksettings is
> >> defined as const.
> >> 
> >> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>  
> > 
> > Did you test this on real hardware?  
> 
> Philippe probably doesn't have physical access to most of the
> drivers he is converting.
> 
> But, he is the only person working on converting all of the drivers,
> and therefore when the change looks straightforward I am going to
> reward his work and effort by applying his changes and hope there
> isn't any fallout.
> 
> Those who really care can test his patches and give a Tested-by:
> 
> Thanks.

Yes, it looks mechanical and should be applied. There are lots of pieces of
old hardware that no developer is running, and if we required full test suite runs
on all drivers, then no refactoring would ever be possible.

My preference is to always add commit note that the patch was compile
tested only so that if someone has a problem with real hardware then they know
what to suspect.
