From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] (updated) netfilter: remove deprecated CONFIG_NF_CT_ACCT
Date: Tue, 20 Oct 2009 17:58:47 +0800
Message-ID: <4ADD89D7.3050902@redhat.com>
References: <20091015080211.4561.78538.sendpatchset@localhost.localdomain> <4AD70FC2.5050302@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org
To: =?ISO-8859-2?Q?Krzysztof_Ol=EAdzki?= <ole@ans.pl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4AD70FC2.5050302@ans.pl>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Sorry that I lost this thread. :(

Krzysztof Ol=EAdzki wrote:
> [resend, previously I incorrectly copied netfilter-devel-owner]
>=20
> Adding CC to netfilter-devel@vger.kernel.org, where netfilter
> related issues are discussed.
>=20
> On Thu, 15 Oct 2009, Amerigo Wang wrote:
>=20
>>
>> CONFIG_NF_CT_ACCT is scheduled to be removed in 2.6.29.
>>
>> Cc: Krzysztof Piotr Oledzki <ole@ans.pl>
>> Signed-off-by: WANG Cong <amwang@redhat.com>
>=20
> This is not so easy - it was decided that we don't want to remove it=20
> just that because of connbytes. The final conclusion was to keep it=20
> disabled by default (if not enabled by kernel/modules/sysctl option) =
but=20
> enabling it automatically for the current NS if nefilter rules contai=
ns=20
> "-m connbytes".
>=20
> Sorry, I should have gotten into this and finished it earlier, my bad=
=2E :(

No problem.

So we just want CONFIG_NF_CT_ACCT=3Dn in default configs?

Thanks!
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
