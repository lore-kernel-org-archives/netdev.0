From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v2 0/9] net: of_phy_connect_fixed_link removal
Date: Thu, 22 May 2014 15:18:17 -0400 (EDT)
Message-ID: <20140522.151817.763033809324051260.davem@davemloft.net>
References: <1400777271-32199-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pantelis.antoniou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	vbordug-hkdhdckH98+B+jHODAdFcQ@public.gmane.org, leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org,
	grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org,
	richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1400777271-32199-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 22 May 2014 09:47:42 -0700

> This patch set removes of_phy_connect_fixed_link() from the tree now that
> we have a better solution for dealing with fixed PHY (emulated PHY) devices
> for drivers that require them.
> 
> First two patches update the 'fixed-link' Device Tree binding and drivers to
> refere to it.
> 
> Patches 3 to 7 update the in-tree network drivers that use
> of_phy_connect_fixed_link()
> 
> Patch 8 removes of_phy_connect_fixed_link
> 
> Patch 9 removes the PowerPC code that parsed the 'fixed-link' property.
> 
> Patch 9 can be merged via the net-next tree if the PowerPC folks ack it,
> but it really has to be merged after the first 8 patches in order to avoid
> breakage.

Series applied, if someone doesn't like patch #9 we can fix it up with a
followup patch or revert.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
