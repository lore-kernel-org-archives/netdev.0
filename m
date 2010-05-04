From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: sctp pull request for net-next-2.6
Date: Tue, 04 May 2010 10:27:14 -0400
Message-ID: <4BE02EC2.3090702@hp.com>
References: <4BDB9777.4020809@hp.com>	<20100503.162148.21319204.davem@davemloft.net> <20100503.162401.102667647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:17133 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932254Ab0EDO1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 10:27:17 -0400
In-Reply-To: <20100503.162401.102667647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 03 May 2010 16:21:48 -0700 (PDT)
>=20
>> From: Vlad Yasevich <vladislav.yasevich@hp.com>
>> Date: Fri, 30 Apr 2010 22:52:39 -0400
>>
>>> The following changes since commit 83d7eb2979cd3390c375470225dd2d8f=
2009bc70:
>>>   Dan Carpenter (1):
>>>         ipv6: cleanup: remove unneeded null check
>>>
>>> are available in the git repository at:
>>>
>>>   git://git.kernel.org/pub/scm/linux/kernel/git/vxy/lksctp-dev.git =
net-next
>> Pulled, thanks Vlad.
>=20
> I had to fix the build when I merged this by adding a missing
> linux/vmalloc.h include to net/sctp/probe.c
>=20
> net/sctp/probe.c: In function =A1sctpprobe_read=A2:
> net/sctp/probe.c:97: error: implicit declaration of function =A1vmall=
oc=A2
> net/sctp/probe.c:97: warning: assignment makes pointer from integer w=
ithout a cast
> net/sctp/probe.c:110: error: implicit declaration of function =A1vfre=
e=A2
>=20

I feel sheeepish.  I just checked my config and realized this thing was=
n't
turned on (my guess it got turned off by the stable builds...).  Sorry =
about that.

-vlad

> diff --git a/net/sctp/probe.c b/net/sctp/probe.c
> index 8f025d5..db3a42b 100644
> --- a/net/sctp/probe.c
> +++ b/net/sctp/probe.c
> @@ -27,6 +27,7 @@
>  #include <linux/socket.h>
>  #include <linux/sctp.h>
>  #include <linux/proc_fs.h>
> +#include <linux/vmalloc.h>
>  #include <linux/module.h>
>  #include <linux/kfifo.h>
>  #include <linux/time.h>
