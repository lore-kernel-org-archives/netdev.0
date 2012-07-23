From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: flush cache according to 'preferred life time'
Date: Mon, 23 Jul 2012 17:44:39 +0800
Message-ID: <500D1D07.3090103@cn.fujitsu.com>
References: <4A71D24947E78D43BC584A7CD4391A41017DE48F@SIXPRD0410MB359.apcprd04.prod.outlook.com>,<500D05D6.7090108@cn.fujitsu.com> <4A71D24947E78D43BC584A7CD4391A41017DE4C1@SIXPRD0410MB359.apcprd04.prod.outlook.com>,<500D0A24.6060200@cn.fujitsu.com> <4A71D24947E78D43BC584A7CD4391A41017DE4FB@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: BALAKUMARAN KANNAN <balakumarank@tataelxsi.co.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:46033 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750969Ab2GWJoZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 05:44:25 -0400
In-Reply-To: <4A71D24947E78D43BC584A7CD4391A41017DE4FB@SIXPRD0410MB359.apcprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B407=E6=9C=8823=E6=97=A5 16:36, BALAKUMARAN KANNAN=
 =E5=86=99=E9=81=93:
> Than you Gao-san. Your patch is helpful. I will try that. Also I am f=
acing another problem. Tahi test case section nd test case 145 is faili=
ng if gc_interval is 30. The test case is as follows
>  * The tester node (tn) sends RA with curhoplimit 64
>  * tn sends a ICMP_REQUEST and checks the ICMP_REPLY from nut is havi=
ng hoplimit 64. (it is fine in my case)
>  * Then the tn sends a RA with curhoplimit 0. (It should be ignored)
>  * Then again tn sends ICMP_REQUEST and checks the ICMP_REPLY from nu=
t whether the hoplimit remains 64 (but it changes to 255 if cache is pr=
esent. But once I changed the gc_interval to 1, this testcase passes)
> Can you please explain what is the reason.=20
>=20

Hi

Can you test with the last kernel?
Maybe this bug has been fixed too.

Thanks
