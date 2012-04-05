From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] phonet: Check input from user before allocating
Date: Thu, 05 Apr 2012 19:06:49 -0400 (EDT)
Message-ID: <20120405.190649.1829697650143132541.davem@davemloft.net>
References: <1333663665-3999-1-git-send-email-levinsasha928@gmail.com>
	<201204052214.55669.remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: levinsasha928@gmail.com, remi.denis-courmont@nokia.com,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: remi@remlab.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201204052214.55669.remi@remlab.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "R=E9mi Denis-Courmont" <remi@remlab.net>
Date: Thu, 5 Apr 2012 22:14:54 +0300

> Le vendredi 6 avril 2012 01:07:45 Sasha Levin, vous avez =E9crit :
>> A phonet packet is limited to USHRT_MAX bytes, this is never checked=
 during
>> tx which means that the user can specify any size he wishes, and the=
 kernel
>> will attempt to allocate that size.
>>=20
>> In the good case, it'll lead to the following warning, but it may al=
so
>> cause the kernel to kick in the OOM and kill a random task on the se=
rver.
 ...
>> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
>=20
> Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied and queued up for -stable, thanks.
