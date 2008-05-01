From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] [POWERPC] mpc5200: Allow for fixed speed MII configurations
Date: Thu, 1 May 2008 10:52:26 -0600
Message-ID: <fa686aa40805010952t58af0071rc308956e9fb13fbf@mail.gmail.com>
References: <20080429230620.11248.25729.stgit@trillian.secretlab.ca>
	 <fa686aa40805010733o6bb5b522hd16669b732f1892@mail.gmail.com>
	 <4819F1F3.2000406@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, paulus@samba.org, netdev@vger.kernel.org,
	wd@denx.de, "Domen Puncer" <domen@coderock.org>,
	"Sylvain Munaut" <tnt@246tnt.com>
To: "Wolfgang Grandegger" <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:7595 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760147AbYEAQw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 12:52:27 -0400
Received: by an-out-0708.google.com with SMTP id d40so219601and.103
        for <netdev@vger.kernel.org>; Thu, 01 May 2008 09:52:27 -0700 (PDT)
In-Reply-To: <4819F1F3.2000406@grandegger.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 1, 2008 at 10:38 AM, Wolfgang Grandegger <wg@grandegger.com> wrote:
> Hi Grant,
>
>
>  Grant Likely wrote:
>  > On Tue, Apr 29, 2008 at 5:06 PM, Grant Likely <grant.likely@secretlab.ca> wrote:
>  >> From: Grant Likely <grant.likely@secretlab.ca>
>  >>
>  >>  Various improvements for configuring the MPC5200 MII link from the
>  >>  device tree:
>  >>  * Look for 'current-speed' property for fixed speed MII links
>  >>  * Look for 'fsl,7-wire-mode' property for boards using the 7 wire mode
>  >>  * move definition of private data structure out of the header file
>  >>
>  >>  Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
>  >
>  > Any more comments on this patch?  I want to push it to Paulus, but I'd
>  > like to have someone ack it first.
>  >
>  > Wolfgang, you used the previous version of this patch.  Does this one
>  > work for you?
>
>  Sorry for the late answer. The patch works fine (under Linux 2.6.24) on
>  my board with a 3-port Micrel ethernet switch. There is still a minor
>  issue, though:
>
>  >>  -               of_node_put(phy_dn);
>  >>  +       /* Start with safe defaults for link connection */
>  >>  +       priv->phy_addr = FEC5200_PHYADDR_NONE;
>  >>  +       priv->speed = 100;
>  >>  +       priv->duplex = 0;
>
>  priv->duplex is re-defined here. And instead of "0" we should use
>  DUPLEX_HALF.

Oops,

Fixed.

If you reply with your 'acked-by' line, then I'll push this one to
Paul so it can get into .26

Thanks,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
