From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 1/4] xen/netback: implements persistent grant
 with one page pool.
Date: Fri, 16 Nov 2012 15:57:12 +0800
Message-ID: <50A5F1D8.20308@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com> <1352963066-570-1-git-send-email-annie.li@oracle.com> <50A4BC7D.6060707@citrix.com> <50A5A9CF.8030008@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: =?ISO-8859-1?Q?Roger_Pau_Monn=E9?= <roger.pau@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25342 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab2KPH5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 02:57:21 -0500
In-Reply-To: <50A5A9CF.8030008@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-16 10:49, ANNIE LI wrote:
>
>
> On 2012-11-15 17:57, Roger Pau Monn=E9 wrote:
>>>
>>> @@ -453,7 +460,12 @@ static int connect_rings(struct backend_info *=
be)
>>>                  val =3D 0;
>>>          vif->csum =3D !val;
>>>
>>> -       /* Map the shared frame, irq etc. */
>>> +       if (xenbus_scanf(XBT_NIL, dev->otherend,=20
>>> "feature-persistent-grants",
>>> +                        "%u",&val)<  0)
>> In block devices "feature-persistent" is used, so I think that for
>> clearness it should be announced the same way in net.
> Is it  "feature-persistent" ? I checked your RFC patch, the key is=20
> "feature-persistent-grants".
>
>
My mistake.
In your v2 patch, it is "feature-persistent". I will change the code as=
=20
blkback/blkfront.

Thanks
Annie
