From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: [PATCH] [POWERPC] mpc5200: Allow for fixed speed MII configurations
Date: Wed, 30 Apr 2008 08:28:18 -0600
Message-ID: <fa686aa40804300728y1a761bf9nd4568b682dc0bb52@mail.gmail.com>
References: <20080429230620.11248.25729.stgit@trillian.secretlab.ca>
	 <1209540962.18445.8.camel@gentoo-jocke.transmode.se>
	 <fa686aa40804300607k72ef9985m43b3c4111cad6085@mail.gmail.com>
	 <1209561053.16926.2.camel@gentoo-jocke.transmode.se>
	 <fa686aa40804300626v41828f64oc3d0d88ff5954825@mail.gmail.com>
	 <1209564975.16926.8.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, linuxppc-dev@ozlabs.org, paulus@samba.org,
	netdev@vger.kernel.org, "Wolfgang Denk" <wd@denx.de>
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:32590 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302AbYD3O2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 10:28:21 -0400
Received: by wx-out-0506.google.com with SMTP id h31so522714wxd.4
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2008 07:28:18 -0700 (PDT)
In-Reply-To: <1209564975.16926.8.camel@gentoo-jocke.transmode.se>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 30, 2008 at 8:16 AM, Joakim Tjernlund
<joakim.tjernlund@transmode.se> wrote:
>
>
>  On Wed, 2008-04-30 at 07:26 -0600, Grant Likely wrote:
>  > On Wed, Apr 30, 2008 at 7:10 AM, Joakim Tjernlund
>  > <joakim.tjernlund@transmode.se> wrote:
>  > >
>  > >
>  > >  On Wed, 2008-04-30 at 07:07 -0600, Grant Likely wrote:
>  > >  > On Wed, Apr 30, 2008 at 1:36 AM, Joakim Tjernlund
>  > >  > <joakim.tjernlund@transmode.se> wrote:
>  > >  > >
>  > >  > >  On Tue, 2008-04-29 at 17:06 -0600, Grant Likely wrote:
>  > >  > >  > From: Grant Likely <grant.likely@secretlab.ca>
>  > >  > >  >
>  > >  > >  > Various improvements for configuring the MPC5200 MII link from the
>  > >  > >  > device tree:
>  > >  > >  > * Look for 'current-speed' property for fixed speed MII links
>  > >  > >
>  > >  > >  Not that I have looked, but why can't you use the fixed-link property?
>  > >  >
>  > >  > fixed-link seems to be a recent invention, whereas current-speed is
>  > >  > better know having already been in use with serial devices.  It seemed
>  > >  > to me to be a better choice, but my opinion can probably be swayed
>  > >  > (arguments welcome).
>  > >
>  > >  yes it is fairly new. You get alot more than just speed: Duplex/Pause
>  > >  You need these too.
>  >
>  > duplex I've got.  pause I don't need.
>
>  dunno how you speify Half/Full Duplex, but isn't it possible that
>  someone else wants to use Pause in the future?
>  Isn't the point that everyone should use fixed-link when it is there
>  for this purpose?

The format of the data is pretty much entirely device dependent (much
like interrupt and gpio specifiers are controller dependent).  I see
any need in trying to define a common format for this data since it is
entirely local to the device.  ie. there is requirement for this data
to be in the same format for every device.  Also, by not trying to
lock it down into a common format it gives future devices freedom to
specify additional flags and parameters in the data.

so,
* gianfar:  needs 5 bits of data.
* 5200 FEC: only needs 2.

As for 'current-speed' vs. 'fixed-link'.  I just think 'current-speed'
is the better name.  :-)

Cheers,
g.

>
>   Jocke
>
>   Jocke
>



-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
