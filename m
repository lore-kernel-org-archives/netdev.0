From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 12:31:56 +0100
Message-ID: <1255347116.2931.3.camel@achroite>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com>
	 <20091009140000.GA18765@mock.linuxdev.us.dell.com>
	 <20091009145137.GD19218@mock.linuxdev.us.dell.com>
	 <1255344075.2143.1.camel@warcraft>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Narendra K <narendra_k@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com
To: Scott James Remnant <scott@ubuntu.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <1255344075.2143.1.camel@warcraft>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-10-12 at 11:41 +0100, Scott James Remnant wrote:
> On Fri, 2009-10-09 at 09:51 -0500, Matt Domsch wrote:
> 
> > As has been noted here, MAC addresses are not necessarily unique to an
> > interface.  As such, we are not proposing a net/by-mac/* symlink to
> > /dev/netdev/*.
> > 
> On the other hand, they *tend* to be unique for a wide range of systems.
> This makes them pretty comparable to LABELs on disks, and we have
> a /dev/disk/by-label
[...]

MAC addresses are normally assigned automatically but can be overridden
if necessary.  In that respect they are more like UUIDs for disks.

I don't see any analogue of disk labels, though labels could conceivably
be added to some NICs using VPD.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

