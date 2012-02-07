From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 3/5] NFS: search for client session id in proper network
 namespace
Date: Tue, 07 Feb 2012 19:50:16 +0400
Message-ID: <4F314838.2060900@parallels.com>
References: <20120126110955.8386.34551.stgit@localhost6.localdomain6> <20120126111149.8386.51043.stgit@localhost6.localdomain6> <4F314688.5050406@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:33962 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755949Ab2BGPuq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 10:50:46 -0500
In-Reply-To: <4F314688.5050406@netapp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

07.02.2012 19:43, Bryan Schumaker =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>
>
> Hi,
>
> You changed this function for the v4.1 case, but not for v4.0 (this i=
s what I was trying to bisect earlier).  Without CONFIG_NFS_V4_1 set, I=
 get this:
>

Sorry. Thank for the catch.
I'll send patch soon.

>   make[1]: Nothing to be done for `all'.
>    CHK     include/linux/version.h
>    CHK     include/generated/utsrelease.h
>    CALL    scripts/checksyscalls.sh
>    CHK     include/generated/compile.h
>    CHK     kernel/config_data.h
>    CC [M]  fs/nfs/client.o
> fs/nfs/client.c:1265:1: error: conflicting types for 'nfs4_find_clien=
t_sessionid'
> fs/nfs/internal.h:155:1: note: previous declaration of 'nfs4_find_cli=
ent_sessionid' was here
> make[2]: *** [fs/nfs/client.o] Error 1
> make[1]: *** [fs/nfs] Error 2
> make: *** [fs] Error 2
>
> - Bryan
>
d


--=20
Best regards,
Stanislav Kinsbursky
