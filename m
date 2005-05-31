From: Mitch Williams <mitch.a.williams@intel.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 31 May 2005 10:35:26 -0700
Message-ID: <Pine.CYG.4.58.0505311029510.2128@mawilli1-desk2.amr.corp.intel.com>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
 <20050527085055.79da3d75@dxpl.pdx.osdl.net>
 <Pine.CYG.4.58.0505271305590.2148@mawilli1-desk2.amr.corp.intel.com>
 <20050527140132.1435132d@dxpl.pdx.osdl.net> <1117241786.6251.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, "Ronciak, John" <john.ronciak@intel.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1117241786.6251.7.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Fri, 27 May 2005, jamal wrote:

>
> On Fri, 2005-27-05 at 14:01 -0700, Stephen Hemminger wrote:
>
> >
> > Why not just allow adjusting dev->weight via sysfs?
>
> I think that should be good enough - and i thought your patch already
> did this.
> Adding a shift to the weight in a _weighted_ RR algorithm does sound
> odd.
>

Stephen's patch only affects the weight for the backlog device.  Exporting
dev-> weight to sysfs will allow the weight to be set for any network
device.  Which makes perfect sense.

I'll work on getting this done and verifying performance this week.
Expect a patch in a few days.

Thanks, guys.

-Mitch
