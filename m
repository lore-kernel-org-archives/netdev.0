From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH iproute2 1/2] ss: Fix compiler errors of unused
 return-values
Date: Mon, 22 Jul 2013 17:14:14 +0200
Message-ID: <20130722151414.GC13263@cpaasch-mac>
References: <1374350298-1177-1-git-send-email-christoph.paasch@uclouvain.be>
 <1374350298-1177-2-git-send-email-christoph.paasch@uclouvain.be>
 <20130722075410.78532ad4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:50146 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755677Ab3GVPOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 11:14:18 -0400
Received: by mail-wg0-f49.google.com with SMTP id a12so6217137wgh.16
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 08:14:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20130722075410.78532ad4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/07/13 - 07:54:10, Stephen Hemminger wrote:
> On Sat, 20 Jul 2013 21:58:17 +0200
> Christoph Paasch <christoph.paasch@uclouvain.be> wrote:
>=20
> > Many errors when compiling with gcc 4.7.3 about unused return-value=
s
> > upon the calls to fgets and fscanf:
> >=20
> > ss.c: In function =E2=80=98user_ent_hash_build=E2=80=99:
> > ss.c:305:12: error: ignoring return value of =E2=80=98fscanf=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> > ss.c: In function =E2=80=98get_slabstat=E2=80=99:
> > ss.c:387:7: error: ignoring return value of =E2=80=98fgets=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> > ss.c: In function =E2=80=98init_service_resolver=E2=80=99:
> > ss.c:511:8: error: ignoring return value of =E2=80=98fgets=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> > ss.c: In function =E2=80=98run_ssfilter=E2=80=99:
> > ss.c:728:11: error: ignoring return value of =E2=80=98fscanf=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> > ss.c: In function =E2=80=98is_ephemeral=E2=80=99:
> > ss.c:550:10: error: ignoring return value of =E2=80=98fscanf=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> > ss.c: In function =E2=80=98netlink_show=E2=80=99:
> > ss.c:2836:7: error: ignoring return value of =E2=80=98fgets=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> > ss.c: In function =E2=80=98packet_show=E2=80=99:
> > ss.c:2630:7: error: ignoring return value of =E2=80=98fgets=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> > ss.c: In function =E2=80=98unix_show=E2=80=99:
> > ss.c:2364:7: error: ignoring return value of =E2=80=98fgets=E2=80=99=
, declared with attribute warn_unused_result [-Werror=3Dunused-result]
> > cc1: all warnings being treated as errors
> > make[1]: *** [ss.o] Error 1
> > make[1]: Leaving directory `/home/christoph/workspace/linux/iproute=
2/misc'
> > make: *** [all] Error 2
> >=20
> > For the calls to fscanf we can't really do anything about it, and j=
ust
> > do an empty if-statement to make the compiler happy.
> >=20
> >
>=20
> I would prefer an error message rather than silently exiting.

Ok, I will resubmit.


Cheers,
Christoph
