From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Tue, 13 Oct 2009 15:53:14 -0400
Message-ID: <20091013195314.GD2747@tuxdriver.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009145137.GD19218@mock.linuxdev.us.dell.com> <1255344075.2143.1.camel@warcraft> <20091012173705.GA22736@nostromo.devel.redhat.com> <1255457182.2196.21.camel@localhost.localdomain> <1255459984.13438.2.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	Bill Nottingham <notting@redhat.com>,
	Scott James Remnant <scott@ubuntu.com>,
	Matt Domsch <Matt_Domsch@dell.com>,
	Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1255459984.13438.2.camel@achroite>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 13, 2009 at 07:53:04PM +0100, Ben Hutchings wrote:
> On Tue, 2009-10-13 at 11:06 -0700, Dan Williams wrote:

> > And if we really want seamless support for MAC spoofing, we want
> > ETHTOOL_GPERMADDR for all drivers too, so that if your configuration
> > says "rename device XX:XX:XX:XX:XX:XX to YY:YY:YY:YY:YY:YY" we can
> > actually figure stuff out after the spoof.
> 
> ETHTOOL_GPERMADDR is handled in the ethtool core now.  Are you thinking
> of drivers that don't have ethtool ops?  Maybe it's time to add default
> operations.

Not quite true -- dev->perm_addr still has to be set by the driver.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
