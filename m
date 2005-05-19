From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was Ethernet Bridging: Enable Hardware Checksumming)
Date: Thu, 19 May 2005 12:47:55 -0500
Message-ID: <200505191247.55138.jdmason@us.ibm.com>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro> <200505191106.53136.jdmason@us.ibm.com> <Pine.LNX.4.62.0505192019090.8076@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0505192019090.8076@webhosting.rdsbv.ro>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 19 May 2005 12:22 pm, Catalin(ux aka Dino) BOIE wrote:
> On Thu, 19 May 2005, Jon Mason wrote:
> > This patch only enables the features which are common between all of the
> > bridged devices (at the time of their addition to the bridge).  It
> > overlooks the cases where not all of the adapters have the same features,
> > or where the user has changed the enablement of a certain feature (via
> > ethtool).
> >
> > Thanks,
> > Jon
>
> I agree that the patch doesn't take care of ethtool oprations.
> I will correct this.

I think trying to correct this could be a bear of a problem.  Good luck.

> But, it doesn't overlook the case when "not all of the adapters have the
> same features". If all devices have a feature, it is enabled on the bridge
> interface. Else, it is cleared. Am I missing your point?

My point is that some features the user might want enabled regardless of 
whether all devices support them.  An example of this is where a system has 
hardware checksum support for all devices except one.  In this case, it would 
be benefitial to have this device do the checksum in software (via 
skb_checksum_help() call in dev_queue_xmit()).

> Thank you very much for looking over the patch!

I really like your patch, and I'm working on combining the two so that we have 
the best of both worlds.  I'll submit it once I have tested it, and we'll see 
who likes it.

Thanks,
Jon
