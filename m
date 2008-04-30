From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] [POWERPC] mpc5200: Allow for fixed speed MII configurations
Date: Wed, 30 Apr 2008 07:07:58 -0600
Message-ID: <fa686aa40804300607k72ef9985m43b3c4111cad6085@mail.gmail.com>
References: <20080429230620.11248.25729.stgit@trillian.secretlab.ca>
	 <1209540962.18445.8.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, linuxppc-dev@ozlabs.org, paulus@samba.org,
	netdev@vger.kernel.org, wd@denx.de, domen.puncer@telargo.com
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:2108 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756592AbYD3NH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 09:07:59 -0400
Received: by an-out-0708.google.com with SMTP id d40so105834and.103
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 06:07:58 -0700 (PDT)
In-Reply-To: <1209540962.18445.8.camel@gentoo-jocke.transmode.se>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 30, 2008 at 1:36 AM, Joakim Tjernlund
<joakim.tjernlund@transmode.se> wrote:
>
>  On Tue, 2008-04-29 at 17:06 -0600, Grant Likely wrote:
>  > From: Grant Likely <grant.likely@secretlab.ca>
>  >
>  > Various improvements for configuring the MPC5200 MII link from the
>  > device tree:
>  > * Look for 'current-speed' property for fixed speed MII links
>
>  Not that I have looked, but why can't you use the fixed-link property?

fixed-link seems to be a recent invention, whereas current-speed is
better know having already been in use with serial devices.  It seemed
to me to be a better choice, but my opinion can probably be swayed
(arguments welcome).

Cheers,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
