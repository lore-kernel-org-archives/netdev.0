From: Song Liu <songliubraving@fb.com>
Subject: Re: [PATCH net-next] tcp: Remove use of inet6_sk and add IPv6 checks
 to tracepoint
Date: Wed, 18 Oct 2017 16:27:52 +0000
Message-ID: <B63D9FF8-2BA1-43FC-B8A5-D3565EF545B6@fb.com>
References: <1508339849-19527-1-git-send-email-dsahern@gmail.com>
 <1508340503.31614.120.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: David Ahern <dsahern@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57608 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751866AbdJRQ2a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 12:28:30 -0400
In-Reply-To: <1508340503.31614.120.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Content-ID: <63076AF7D1CB8044A7D1EBC49F661CAA@namprd15.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Oct 18, 2017, at 8:28 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> On Wed, 2017-10-18 at 08:17 -0700, David Ahern wrote:
>> 386fd5da401d ("tcp: Check daddr_cache before use in tracepoint") was the
>> second version of the tracepoint fixup patch. This patch is the delta
>> between v2 and v3.  Specifically, remove the use of inet6_sk and check
>> sk_family as requested by Eric and add IS_ENABLED(CONFIG_IPV6) around
>> the use of sk_v6_rcv_saddr and sk_v6_daddr as done in sock_common (noted
>> by Cong).
>>=20
>> Signed-off-by: David Ahern <dsahern@gmail.com>
>> ---
>=20
> Reviewed-by: Eric Dumazet <edumazet@google.com>
>=20
> Thanks !
>=20

Tested-by: Song Liu <songliubraving@fb.com>
