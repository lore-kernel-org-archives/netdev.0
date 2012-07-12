From: Li Wei <lw@cn.fujitsu.com>
Subject: Re: [PATCH] tc_util: fix incorrect bare number process in get_rate.
Date: Thu, 12 Jul 2012 09:16:48 +0800
Message-ID: <4FFE2580.7020404@cn.fujitsu.com>
References: <4FFD2A42.9080507@cn.fujitsu.com> <20120711075129.4f81eea8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:11677 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756049Ab2GLBR3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 21:17:29 -0400
In-Reply-To: <20120711075129.4f81eea8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012-7-11 22:51, Stephen Hemminger =E5=86=99=E9=81=93:
> On Wed, 11 Jul 2012 15:24:50 +0800
> Li Wei <lw@cn.fujitsu.com> wrote:
>=20
>>
>> As the comment and manpage indicated that the bare number means
>> bytes per second, so the division is not needed.
>> ---
>>  tc/tc_util.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/tc/tc_util.c b/tc/tc_util.c
>> index 926ed08..e8d89c1 100644
>> --- a/tc/tc_util.c
>> +++ b/tc/tc_util.c
>> @@ -153,7 +153,7 @@ int get_rate(unsigned *rate, const char *str)
>>  		return -1;
>> =20
>>  	if (*p =3D=3D '\0') {
>> -		*rate =3D bps / 8.;	/* assume bytes/sec */
>> +		*rate =3D bps;	/* assume bytes/sec */
>>  		return 0;
>>  	}
>> =20
> Thanks for finding this. The documentation, code and comment do
> all need to be the same!
>=20
> But changing the code as you propose would break existing usage
> by scripts. Instead, the man page and comment need to change
> to match the reality of the existing application.
>=20
>=20
Well, I see, I'll send another patch to take care of this.

Thanks,

Wei
