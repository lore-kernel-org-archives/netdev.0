From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH v4] ipv6: Fix problem with expired dst cache
Date: Mon, 05 Mar 2012 15:10:34 +0800
Message-ID: <4F5466EA.3020707@cn.fujitsu.com>
References: <1330064404-24763-1-git-send-email-gaofeng@cn.fujitsu.com> <1330919628-11837-1-git-send-email-gaofeng@cn.fujitsu.com> <20120305.000558.923755086046890012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:24356 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752563Ab2CEHJk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 02:09:40 -0500
In-Reply-To: <20120305.000558.923755086046890012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B403=E6=9C=8805=E6=97=A5 13:05, David Miller =E5=86=
=99=E9=81=93:
> From: Gao feng <gaofeng@cn.fujitsu.com>
> Date: Mon, 5 Mar 2012 11:53:48 +0800
>=20
>> +		/* point to where the dst_entry copied from */
>> +		void			*from;
>=20
> So instead of using a real type here, your just going to cast
> this thing to and from "struct dst_entry *" a thousand times?
>=20
> That's terrible, there is zero value from using a void pointer
> here, it just makes the code look ugly.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

Hi David
You are right.I will resend this patch changes void * to dst_entry *.

thanks for your patience.
