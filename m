From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 13:40:52 -0700
Message-ID: <571697D4.5090404@cumulusnetworks.com>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com> <5715EBCF.20801@6wind.com> <CAHC9VhRjjWk9drwY5Db2Zwu1CHw+dxtkMKR6Ovw3pzuHBvieVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	jhs@mojatatu.com, davem@davemloft.net, tgraf@suug.ch,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@parisplace.org>
To: Paul Moore <paul@paul-moore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34299 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932155AbcDSUkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 16:40:55 -0400
Received: by mail-pf0-f176.google.com with SMTP id c20so10212754pfc.1
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 13:40:55 -0700 (PDT)
In-Reply-To: <CAHC9VhRjjWk9drwY5Db2Zwu1CHw+dxtkMKR6Ovw3pzuHBvieVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/19/16, 12:55 PM, Paul Moore wrote:
> On Tue, Apr 19, 2016 at 4:26 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> + selinux maintainers
>>
>> Le 18/04/2016 23:10, Roopa Prabhu a =C3=A9crit :
>> [snip]
>>> diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgta=
b.c
>>> index 8495b93..1714633 100644
>>> --- a/security/selinux/nlmsgtab.c
>>> +++ b/security/selinux/nlmsgtab.c
>>> @@ -76,6 +76,8 @@ static struct nlmsg_perm nlmsg_route_perms[] =3D
>>>         { RTM_NEWNSID,          NETLINK_ROUTE_SOCKET__NLMSG_WRITE }=
,
>>>         { RTM_DELNSID,          NETLINK_ROUTE_SOCKET__NLMSG_READ  }=
,
>>>         { RTM_GETNSID,          NETLINK_ROUTE_SOCKET__NLMSG_READ  }=
,
>>> +       { RTM_NEWSTATS,         NETLINK_ROUTE_SOCKET__NLMSG_WRITE }=
,
>> I would say it's NETLINK_ROUTE_SOCKET__NLMSG_READ, not WRITE. This c=
ommand
>> is only sent by the kernel, not by the userland.
> From what I could tell from the patch description, it looks like
> RTM_NEWSTATS only dumps stats to userspace and doesn't alter the stat=
e
> of the kernel, is that correct?  If so, then yes, NLMSG__READ is the
> right SELinux permission.  However, if RTM_NEWSTATS does alter the
> state/configuration of the kernel then we should use NLMSG__WRITE.
>
okay, will change it to READ in the next version,

thanks.
