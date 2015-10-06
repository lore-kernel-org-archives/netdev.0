From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] bridge/netfilter: avoid unused label warning
Date: Tue, 6 Oct 2015 23:02:45 +0200
Message-ID: <561436F5.70409@cumulusnetworks.com>
References: <7985748.1v9Gzszd4T@wuerfel> <561420DD.70009@cumulusnetworks.com>
 <5966552.c0Emgm27oa@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5966552.c0Emgm27oa@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/06/2015 09:39 PM, Arnd Bergmann wrote:
> On Tuesday 06 October 2015 21:28:29 Nikolay Aleksandrov wrote:
>> I posted a fix for this a couple of days ago, but I like your approa=
ch better.
>> Since mine is not yet applied (I sent it to netfilter-devel only, wa=
sn't sure which
>> jurisdiction this falls into exactly) we can drop it.
>> Just for reference my patch is here:
>> http://patchwork.ozlabs.org/patch/526417/
>> Pablo, could you please drop it ?
>>
>> By the way this takes care of another warning about unused variable =
(nf_bridge), too.
>=20
> Hmm I did not get that one, at least not in 4.3-rc4.
>=20
You need to set W=3D1
$ git describe --abbrev=3D0
v4.3-rc4

net/bridge//br_netfilter_hooks.c: In function =91br_nf_dev_queue_xmit=92=
:
net/bridge//br_netfilter_hooks.c:794:2: warning: label =91drop=92 defin=
ed but not used [-Wunused-label]
  drop:
  ^
net/bridge//br_netfilter_hooks.c:727:25: warning: variable =91nf_bridge=
=92 set but not used [-Wunused-but-set-variable]
  struct nf_bridge_info *nf_bridge;

Cheers,
 Nik

>> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>=20
> Thanks and sorry for missing the Cc to the netfilter list on my patch=
=2E
>=20
> 	Arnd
