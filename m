From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 3/4] Xen/netfront: Implement persistent grant
 in netfront.
Date: Fri, 16 Nov 2012 15:58:54 +0800
Message-ID: <50A5F23E.4090506@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com> <1352963114-628-1-git-send-email-annie.li@oracle.com> <50A4C987.3020308@citrix.com> <50A5CD7F.2010609@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: =?ISO-8859-1?Q?Roger_Pau_Monn=E9?= <roger.pau@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34890 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab2KPH7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 02:59:03 -0500
In-Reply-To: <50A5CD7F.2010609@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-16 13:22, ANNIE LI wrote:
>
>
> On 2012-11-15 18:52, Roger Pau Monn=E9 wrote:
>>> +       err =3D xenbus_printf(xbt, dev->nodename,=20
>>> "feature-persistent-grants",
>>> +                           "%u", info->persistent_gnt);
>> As in netback, I think "feature-persistent" should be used.
>
> Same in blkback, I assume it is  "feature-persistent-grants", right?
> I referred your RFC patch, did you change it later? Or I missed=20
> something?
>
>
My mistake.
In your v2 patch, it is "feature-persistent". I will change the code as=
=20
blkback/blkfront.

Thanks
Annie
