From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] [POWERPC] mpc5200: Allow for fixed speed MII
	configurations
Date: Wed, 30 Apr 2008 17:04:02 +0200
Message-ID: <1209567842.16926.27.camel@gentoo-jocke.transmode.se>
References: <20080429230620.11248.25729.stgit@trillian.secretlab.ca>
	<1209540962.18445.8.camel@gentoo-jocke.transmode.se>
	<fa686aa40804300607k72ef9985m43b3c4111cad6085@mail.gmail.com>
	<1209561053.16926.2.camel@gentoo-jocke.transmode.se>
	<fa686aa40804300626v41828f64oc3d0d88ff5954825@mail.gmail.com>
	<1209564975.16926.8.camel@gentoo-jocke.transmode.se>
	<fa686aa40804300728y1a761bf9nd4568b682dc0bb52@mail.gmail.com>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, paulus@samba.org, netdev@vger.kernel.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <fa686aa40804300728y1a761bf9nd4568b682dc0bb52@mail.gmail.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Wed, 2008-04-30 at 08:28 -0600, Grant Likely wrote:
> On Wed, Apr 30, 2008 at 8:16 AM, Joakim Tjernlund
> <joakim.tjernlund@transmode.se> wrote:
> >
> >
> >  On Wed, 2008-04-30 at 07:26 -0600, Grant Likely wrote:
> >  > On Wed, Apr 30, 2008 at 7:10 AM, Joakim Tjernlund
> >  > <joakim.tjernlund@transmode.se> wrote:
> >  > >
> >  > >
> >  > >  On Wed, 2008-04-30 at 07:07 -0600, Grant Likely wrote:
> >  > >  > On Wed, Apr 30, 2008 at 1:36 AM, Joakim Tjernlund
> >  > >  > <joakim.tjernlund@transmode.se> wrote:
> >  > >  > >
> >  > >  > >  On Tue, 2008-04-29 at 17:06 -0600, Grant Likely wrote:
> >  > >  > >  > From: Grant Likely <grant.likely@secretlab.ca>
> >  > >  > >  >
> >  > >  > >  > Various improvements for configuring the MPC5200 MII link from the
> >  > >  > >  > device tree:
> >  > >  > >  > * Look for 'current-speed' property for fixed speed MII links
> >  > >  > >
> >  > >  > >  Not that I have looked, but why can't you use the fixed-link property?
> >  > >  >
> >  > >  > fixed-link seems to be a recent invention, whereas current-speed is
> >  > >  > better know having already been in use with serial devices.  It seemed
> >  > >  > to me to be a better choice, but my opinion can probably be swayed
> >  > >  > (arguments welcome).
> >  > >
> >  > >  yes it is fairly new. You get alot more than just speed: Duplex/Pause
> >  > >  You need these too.
> >  >
> >  > duplex I've got.  pause I don't need.
> >
> >  dunno how you speify Half/Full Duplex, but isn't it possible that
> >  someone else wants to use Pause in the future?
> >  Isn't the point that everyone should use fixed-link when it is there
> >  for this purpose?
> 
> The format of the data is pretty much entirely device dependent (much
> like interrupt and gpio specifiers are controller dependent).  I see
> any need in trying to define a common format for this data since it is
> entirely local to the device.  ie. there is requirement for this data
> to be in the same format for every device.  Also, by not trying to
> lock it down into a common format it gives future devices freedom to
> specify additional flags and parameters in the data.
> 
> so,
> * gianfar:  needs 5 bits of data.
> * 5200 FEC: only needs 2.
> 
> As for 'current-speed' vs. 'fixed-link'.  I just think 'current-speed'
> is the better name.  :-)

Then some day someone else needs Pause or need to control Duplex. Then
you end up with several impl. Maybe fixed-link isn't the best 
name, but it is designed for this purpose.

Anyhow, I not going to argue this more. Seems like I am the
only one thinking it would be better to use fixed-link instead so I 
guess I am wrong here.

 Jocke
