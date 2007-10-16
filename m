From: Joachim Fenkes <fenkes@de.ibm.com>
Subject: Re: [PATCH 4/5] ibmebus: Move to of_device and of_platform_driver, match eHCA and eHEA drivers
Date: Tue, 16 Oct 2007 23:20:00 +0200
Message-ID: <200710162320.00630.fenkes@de.ibm.com>
References: <OF48E0997F.B61F7220-ONC125736F.002D7F06-C125736F.002DD39C@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"LinuxPPC-Dev" <linuxppc-dev@ozlabs.org>,
	Paul Mackerras <pmac@au1.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Thomas Q Klein <tklein@de.ibm.com>, netdev@vger.kernel.org,
	Marcus Eder <meder@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:28268 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755248AbXJPOUh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:20:37 -0400
In-Reply-To: <OF48E0997F.B61F7220-ONC125736F.002D7F06-C125736F.002DD39C@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 October 2007 10:21, Jan-Bernd Themann wrote:
> Roland Dreier <rdreier@cisco.com> wrote on 03.10.2007 20:05:44:
> >  > > Replace struct ibmebus_dev and struct ibmebus_driver with stru=
ct=20
of_device
> >  > > and struct of_platform_driver, respectively. Match the externa=
l=20
ibmebus
> >  > > interface and drivers using it.
> >  > >
> >  > > Signed-off-by: Joachim Fenkes <fenkes@de.ibm.com>
> >  >
> >  > This is somewhat difficult as this patch touches files that are =
the
> >  > responsibility of three different maintainers. =A0Is it possible=
 to
> >  > split the patch into three, one for each maintainer (possibly by
> >  > keeping both old and new interfaces around for a little while)?
> >  >=20
> >  > If not, then you need to get an Acked-by and an agreement that t=
his
> >  > change can go via the powerpc.git tree from Roland Dreier and Je=
ff
> >  > Garzik.
> >
> > I don't see anything objectionable in the infiniband parts of the
> > patch -- I don't have any way to test the changes but it all looks
> > like a straightforward conversion to a new platform API.  So:
> >
> > Acked-by: Roland Dreier <rolandd@cisco.com>
> >
> >  - R.
>
> Looks good from eHEA driver perspective.
>
> Acked-by: Jan-Bernd Themann <themann@de.ibm.com>

Jeff, do you have any objections against this patch going into the kern=
el
via Paul's powerpc.git tree? It touches only a few lines of ehea which =
are
specific to the bus interface changes.

You can see the full patch here:
  http://patchwork.ozlabs.org/linuxppc/patch?id=3D13750

If you have no objections, please ack the patch so Paul can include it.

Thanks and regards,
  Joachim

