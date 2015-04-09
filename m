From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 2/5] selinux/nlmsg: add RTM_GETNSID
Date: Thu, 09 Apr 2015 15:10:07 +0200
Message-ID: <55267A2F.5050609@6wind.com>
References: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>	<1428511002-22329-3-git-send-email-nicolas.dichtel@6wind.com> <CAHC9VhSp_0v+Qd3epkT4rVrP3iqS7A+vhq1TWPN6b76jk1Wpdw@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paul Moore <paul@paul-moore.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <CAHC9VhSp_0v+Qd3epkT4rVrP3iqS7A+vhq1TWPN6b76jk1Wpdw@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 09/04/2015 13:10, Paul Moore a =C3=A9crit :
[snip]
>> --- a/security/selinux/nlmsgtab.c
>> +++ b/security/selinux/nlmsgtab.c
>> @@ -74,6 +74,7 @@ static struct nlmsg_perm nlmsg_route_perms[] =3D
>>          { RTM_DELMDB,           NETLINK_ROUTE_SOCKET__NLMSG_WRITE  =
},
>>          { RTM_GETMDB,           NETLINK_ROUTE_SOCKET__NLMSG_READ  }=
,
>>          { RTM_NEWNSID,          NETLINK_ROUTE_SOCKET__NLMSG_WRITE }=
,
>> +       { RTM_DELNSID,          NETLINK_ROUTE_SOCKET__NLMSG_READ  },
>>          { RTM_GETNSID,          NETLINK_ROUTE_SOCKET__NLMSG_READ  }=
,
>>   };
>
> Can you elaborate a bit on the RTM_DELNSID type?  Based only on the
> name I wonder if it should be treated as a "write" and not a "read"
> operation.
The user is not allowed to delete a nsid (no method is implemented). Th=
is
RTM_DELNSID is only used for notifications.
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
