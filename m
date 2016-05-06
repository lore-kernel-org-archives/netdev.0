From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net 0/3] mlxsw: Couple of fixes
Date: Fri, 6 May 2016 22:13:49 +0200
Message-ID: <20160506201349.GA1973@nanopsycho.orion>
References: <1462526244-11898-1-git-send-email-jiri@resnulli.us>
 <20160506.160032.988131639794984436.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38258 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758691AbcEFUNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:13:52 -0400
Received: by mail-wm0-f52.google.com with SMTP id g17so94434119wme.1
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 13:13:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160506.160032.988131639794984436.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ri, May 06, 2016 at 10:00:32PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri,  6 May 2016 11:17:21 +0200
>
>> From: Jiri Pirko <jiri@mellanox.com>
>>=20
>> Ido Schimmel (2):
>>   mlxsw: spectrum: Fix rollback order in LAG join failure
>>   mlxsw: spectrum: Add missing rollback in flood configuration
>>=20
>> Jiri Pirko (1):
>>   mlxsw: spectrum: Fix ordering in mlxsw_sp_fini
>
>What tree is this for?  Because on 'net' this makes the build fail.
>
>drivers/net/ethernet/mellanox/mlxsw/spectrum.c: In function =E2=80=98m=
lxsw_sp_fini=E2=80=99:
>drivers/net/ethernet/mellanox/mlxsw/spectrum.c:2162:2: error: implicit=
 declaration of function =E2=80=98mlxsw_sp_buffers_fini=E2=80=99 [-Werr=
or=3Dimplicit-function-declaration]
>

Oh. Ido's patches are for -net, mine if for -net-next. I did't realize,
sorry. Do you want me to repost?
