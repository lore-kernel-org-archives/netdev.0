From: Wolfgang Denk <wd@denx.de>
Subject: Re: [PATCH 2/2 v4] MPC52xx FEC: be more conservative when setting MII_SPEED register
Date: Fri, 17 Jul 2009 19:51:38 +0200
Message-ID: <20090717175138.97CB2832E416@gemini.denx.de>
References: <1247833628-15952-2-git-send-email-wd@denx.de> <1247835545-18650-1-git-send-email-wd@denx.de> <fa686aa40907170745h6c5fae6bia0cff0926c93393c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:52491 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964849AbZGQRvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2009 13:51:44 -0400
In-reply-to: <fa686aa40907170745h6c5fae6bia0cff0926c93393c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Grant Likely,

In message <fa686aa40907170745h6c5fae6bia0cff0926c93393c@mail.gmail.com> you wrote:
>
> >  drivers/net/fec_mpc52xx.c     |   25 ++++++++++++++++++++++---
> >  drivers/net/fec_mpc52xx_phy.c |   23 ++++++++++++++++++++---
>
> Blech.  now this block of duplicated code I don't like.  This is all
> one device, so surely the mdio speed can be calculated once and used
> for both drivers.... let me think about this for a bit.  'course this
> problem is all rolled up in the nastiness of having two drivers
> working on the same device.  I suspect is was a mistake to split up
> all the powerpc ethernet drivers into separate of_platform drivers.

If you like, I can re-introduce the mpc5xxx_get_mii_speed() I unrolled
upon your request (with or without re-using it for the MPC512x case).


Best regards,

Wolfgang Denk

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
Phone: (+49)-8142-66989-10 Fax: (+49)-8142-66989-80 Email: wd@denx.de
What is mind?  No matter.  What is matter?  Never mind.
                                      -- Thomas Hewitt Key, 1799-1875
