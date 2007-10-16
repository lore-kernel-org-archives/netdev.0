From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/5] ibmebus: Move to of_device and of_platform_driver,
 match eHCA and eHEA drivers
Date: Tue, 16 Oct 2007 11:00:26 -0400
Message-ID: <4714D20A.3080607@garzik.org>
References: <OF48E0997F.B61F7220-ONC125736F.002D7F06-C125736F.002DD39C@de.ibm.com> <200710162320.00630.fenkes@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan-Bernd Themann <THEMANN@de.ibm.com>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	LinuxPPC-Dev <linuxppc-dev@ozlabs.org>,
	Paul Mackerras <pmac@au1.ibm.com>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Thomas Q Klein <tklein@de.ibm.com>, netdev@vger.kernel.org,
	Marcus Eder <meder@de.ibm.com>
To: Joachim Fenkes <fenkes@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33852 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755248AbXJPPAm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 11:00:42 -0400
In-Reply-To: <200710162320.00630.fenkes@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joachim Fenkes wrote:
> On Tuesday 09 October 2007 10:21, Jan-Bernd Themann wrote:
>> Roland Dreier <rdreier@cisco.com> wrote on 03.10.2007 20:05:44:
>>>  > > Replace struct ibmebus_dev and struct ibmebus_driver with stru=
ct=20
> of_device
>>>  > > and struct of_platform_driver, respectively. Match the externa=
l=20
> ibmebus
>>>  > > interface and drivers using it.
>>>  > >
>>>  > > Signed-off-by: Joachim Fenkes <fenkes@de.ibm.com>
>>>  >
>>>  > This is somewhat difficult as this patch touches files that are =
the
>>>  > responsibility of three different maintainers. =EF=BF=BDIs it po=
ssible to
>>>  > split the patch into three, one for each maintainer (possibly by
>>>  > keeping both old and new interfaces around for a little while)?
>>>  >=20
>>>  > If not, then you need to get an Acked-by and an agreement that t=
his
>>>  > change can go via the powerpc.git tree from Roland Dreier and Je=
ff
>>>  > Garzik.
>>>
>>> I don't see anything objectionable in the infiniband parts of the
>>> patch -- I don't have any way to test the changes but it all looks
>>> like a straightforward conversion to a new platform API.  So:
>>>
>>> Acked-by: Roland Dreier <rolandd@cisco.com>
>>>
>>>  - R.
>> Looks good from eHEA driver perspective.
>>
>> Acked-by: Jan-Bernd Themann <themann@de.ibm.com>
>=20
> Jeff, do you have any objections against this patch going into the ke=
rnel
> via Paul's powerpc.git tree? It touches only a few lines of ehea whic=
h are
> specific to the bus interface changes.
>=20
> You can see the full patch here:
>   http://patchwork.ozlabs.org/linuxppc/patch?id=3D13750
>=20
> If you have no objections, please ack the patch so Paul can include i=
t.

=46ine with me...

	Jeff



