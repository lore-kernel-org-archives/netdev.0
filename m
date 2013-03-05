From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net/rds: using strlcpy instead of strncpy
Date: Tue, 05 Mar 2013 10:32:22 +0800
Message-ID: <51355936.3060307@asianux.com>
References: <512F1534.9020404@asianux.com>  <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>  <1362421944.2956.15.camel@bwh-desktop.uk.solarflarecom.com> <1362422090.2956.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>,
	venkat.x.venkatsubra@oracle.com,
	David Miller <davem@davemloft.net>, rds-devel@oss.oracle.com,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:42184 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab3CECcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 21:32:46 -0500
In-Reply-To: <1362422090.2956.18.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B403=E6=9C=8805=E6=97=A5 02:34, Ben Hutchings =E5=86=
=99=E9=81=93:
> On Mon, 2013-03-04 at 18:32 +0000, Ben Hutchings wrote:
>> > On Thu, 2013-02-28 at 09:36 +0000, David Laight wrote:
>>> > >=20
>>> > > If the target buffer ends up being copied to userspace that
>>> > > might lead to random kernel memory being leaked.
>> >=20
>> > Seems it is.  The last byte of 'name' is not currently initialised=
 and
>> > therefore is already leaked to userland.
>> >=20
>> > But it's OK because rds_info_copy() uses memcpy() not __copy_to_us=
er(),
>> > so SMAP will block this leak. :-)
> Or not, as kmap() presumably evades that.

 is this patch ok, or need improving ?

BTW:
  excuse me, maybe my reply will be late during this week.
  the reason:
    my father had a serious heart disease, and is in hospital.
    during these days, most of my time has to be in hospital.
      (God Bless, and thank Jesus Christ, my father is safe, now).
    within my company (Asianux), I also have something to do.


 :-)

--=20
Chen Gang

Asianux Corporation
