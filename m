From: fangxiaozhi 00110321 <huananhu@huawei.com>
Subject: Re: [PATCH 23/10]Optimize the upload speed for PPP connection.
Date: Tue, 17 Nov 2009 16:45:30 +0800
Message-ID: <f9f4a7c31b02f.1b02ff9f4a7c3@huawei.com>
References: <fb8ed0e9a479.a479fb8ed0e9@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, davem@davemloft.net,
	william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:63610 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbZKQIpc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 03:45:32 -0500
Received: from huawei.com (szxga03-in [172.24.2.9])
 by szxga03-in.huawei.com (iPlanet Messaging Server 5.2 HotFix 2.14 (built Aug
 8 2006)) with ESMTP id <0KT8006GTWBVQO@szxga03-in.huawei.com> for
 netdev@vger.kernel.org; Tue, 17 Nov 2009 16:45:31 +0800 (CST)
Received: from huawei.com ([172.17.1.31])
 by szxga03-in.huawei.com (iPlanet Messaging Server 5.2 HotFix 2.14 (built Aug
 8 2006)) with ESMTP id <0KT800M1DWBUZV@szxga03-in.huawei.com> for
 netdev@vger.kernel.org; Tue, 17 Nov 2009 16:45:30 +0800 (CST)
In-reply-to: <fb8ed0e9a479.a479fb8ed0e9@huawei.com>
Content-language: zh-CN
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All:

    Excuse me, how about my patch now?
   =20
    Will my patch be fixed in the newest kernel version? What version i=
s it?


Best Regards,

=46ranko Fang
2009-11-17
----- =D4=AD=D3=CA=BC=FE -----
=B7=A2=BC=FE=C8=CB: fangxiaozhi 00110321 <huananhu@huawei.com>
=C8=D5=C6=DA: =D0=C7=C6=DA=C8=FD, =CA=AE=D4=C2 28=C8=D5, 2009 =CF=C2=CE=
=E73:30
=D6=F7=CC=E2: Re: PATCH 23/10]Optimize the upload speed for PPP connect=
ion.
=CA=D5=BC=FE=C8=CB: davem@davemloft.net,william.allen.simpson@gmail.com
=B3=AD=CB=CD: netdev@vger.kernel.org,kernel@vger.kernel.org,zihan@huawe=
i.com, greg@kroah.com,haegar@sdinet.de

>=20
> Thanks your advice.
>=20
> But generally, PAGE_SIZE is 4096, whether it is too large or not?
>=20
> If PAGE_SIZE is really appropriate, then I can resubmit the patch.
>=20
> Thanks very much.
> ----- Original Message -----=20
> From: "David Miller" <davem@davemloft.net>
> To: <william.allen.simpson@gmail.com>
> Cc: <huananhu@huawei.com>; <netdev@vger.kernel.org>; <linux-
> kernel@vger.kernel.org>; <zihan@huawei.com>; <greg@kroah.com>;=20
> <haegar@sdinet.de>Sent: Saturday, October 24, 2009 9:46 PM
> Subject: Re: PATCH 23/10]Optimize the upload speed for PPP connection=
=2E
>=20
>=20
> > From: William Allen Simpson <william.allen.simpson@gmail.com>
> > Date: Fri, 23 Oct 2009 07:46:08 -0400
> >=20
> >> Concur.  I'd go further than that, my code usually made room=20
> for at
> >> least
> >> a full MTU (MRU) with HDLC escaping.  To minimize context switches=
,
> >> that
> >> should be 3014 ((1500 MRU + 2 FCS + 4 header) * 2 escapes + 2=20
> flags).>>=20
> >> Even in the old days, when memory was tight, context switches and
> >> interrupt
> >> time were more expensive, too.  PPP is supposed to scale to OC-192=
=2E
> >=20
> > Actually I'd like to see ->obuf allocated externally and then
> > make it simply PAGE_SIZE.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-
> kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-
> kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> *********************************************************************=
*********************
> This email and its attachments contain confidential information=20
> from HUAWEI, which is intended only for the person or entity whose=20
> address is listed above. Any use of the information contained here=20
> in any way (including, but not limited to, total or partial=20
> disclosure, reproduction, or dissemination) by persons other than=20
> the intended recipient(s) is prohibited. If you receive this email=20
> in error, please notify the sender by phone or email
> immediately and delete it!
>=20
> *********************************************************************=
********************
