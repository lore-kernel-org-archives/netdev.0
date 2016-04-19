From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 10:26:55 +0200
Message-ID: <5715EBCF.20801@6wind.com>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jhs@mojatatu.com, davem@davemloft.net, tgraf@suug.ch,
	Paul Moore <paul@paul-moore.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36888 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031AbcDSI07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 04:26:59 -0400
Received: by mail-wm0-f45.google.com with SMTP id n3so16324200wmn.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 01:26:58 -0700 (PDT)
In-Reply-To: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ selinux maintainers

Le 18/04/2016 23:10, Roopa Prabhu a =C3=A9crit :
[snip]
> diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.=
c
> index 8495b93..1714633 100644
> --- a/security/selinux/nlmsgtab.c
> +++ b/security/selinux/nlmsgtab.c
> @@ -76,6 +76,8 @@ static struct nlmsg_perm nlmsg_route_perms[] =3D
>   	{ RTM_NEWNSID,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
>   	{ RTM_DELNSID,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
>   	{ RTM_GETNSID,		NETLINK_ROUTE_SOCKET__NLMSG_READ  },
> +	{ RTM_NEWSTATS,		NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
I would say it's NETLINK_ROUTE_SOCKET__NLMSG_READ, not WRITE. This comm=
and is
only sent by the kernel, not by the userland.
