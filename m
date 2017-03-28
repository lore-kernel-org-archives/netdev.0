From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/1] ethtool : added
 get_phy_stats,get_strings,get_sset_count
Date: Tue, 28 Mar 2017 14:10:29 +0200
Message-ID: <20170328121029.GB3152@lunn.ch>
References: <1490609570-3571-1-git-send-email-thomasscariah@gmail.com>
 <5153db09-092f-55b1-a8fc-aa23433c52a0@gmail.com>
 <CA+1hMaGV-trVT+ZisgTtyRAVz=ZqopmwmpWyqHvWQMrkmv-96A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, nsekhar@ti.com,
        grygorii.strashko@ti.com, davem@davemloft.net,
        drivshin@allworx.com, mugunthanvnm@ti.com,
        ivan.khoronzhuk@linaro.org,
        Thomas Scariah <thomas.scariah@harman.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Scariah <thomasscariah@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+1hMaGV-trVT+ZisgTtyRAVz=ZqopmwmpWyqHvWQMrkmv-96A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 11:56:40AM +0530, Thomas Scariah wrote:
> Hello Florian/Andrew,
> 
> 
> On Mon, Mar 27, 2017 at 10:14 PM, Florian Fainelli <f.fainelli@gmail.com>
> wrote:
> 
> > Hello,
> >
> > On 03/27/2017 03:12 AM, Thomas Scariah wrote:
> > > From: "Scariah, Thomas" <thomas.scariah@harman.com>
> > >
> > >  Added functions to support ethtool to print the phy statistics and error
> > >  information along with other ethtool statistics. This will help ethtool
> > >  information to know the error is from physical layer or MAC layer.
> > >  This is an enahancement for ethtool to accommodate phy statistics
> >
> > It sounds like your patch should actually be 3 different patches:
> >
> > - add helper function to the core PHY library
> > - add statistics support to the Micrel PHY driver
> > - hook the proper ndo operations in cpsw to allow querying the PHY
> > driver's statistics
> >
> 
> Yes agreed. This can be 3 different patches .
> Anyway the latest kernel already has the same change.
> I have developed this patch against Kernel 4.4.14 and the similar
> functionality was not available.

Hi Thomas

O.K, using v4.4 explains a lot. However, we only accept patches
against:

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git

I still suggest you only do the PHY driver parts, and don't touch the
MAC driver.

	Andrew
