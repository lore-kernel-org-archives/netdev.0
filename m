From: =?utf-8?B?6auY5bOw?= <fgao@ikuai8.com>
Subject: =?utf-8?Q?=E7=AD=94=E5=A4=8D:_=E7=AD=94=E5=A4=8D:_=5BPATCH_1/1=5D_netfilt?=
	=?utf-8?Q?er:_Add_helper_array_register/un?=
	=?utf-8?Q?register_functions?=
Date: Wed, 20 Jul 2016 16:57:32 +0800
Message-ID: <016801d1e264$c194b390$44be1ab0$@ikuai8.com>
References: <1468813163-18139-1-git-send-email-fgao@ikuai8.com> <20160719181250.GA6116@salvia> <014e01d1e21e$062884b0$12798e10$@ikuai8.com> <20160720085018.GD1336@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <kaber@trash.net>, <netfilter-devel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<gfree.wind@gmail.com>
To: "'Pablo Neira Ayuso'" <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160720085018.GD1336@salvia>
Content-Language: zh-cn
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ok, I get it.=20
Thanks Pablo.

Another question, Liping found the port style of sip, irc, and tftp was=
 different with ftp.
It should be use iterator "i" to generate name for them.
Then should I update the original patch or create another one to correc=
t it?

BTW, I am sorry about that. I didn't notice there are two port styles.

-----=E9=82=AE=E4=BB=B6=E5=8E=9F=E4=BB=B6-----
=E5=8F=91=E4=BB=B6=E4=BA=BA: Pablo Neira Ayuso [mailto:pablo@netfilter.=
org]=20
=E5=8F=91=E9=80=81=E6=97=B6=E9=97=B4: 2016=E5=B9=B47=E6=9C=8820=E6=97=A5=
 16:50
=E6=94=B6=E4=BB=B6=E4=BA=BA: =E9=AB=98=E5=B3=B0 <fgao@ikuai8.com>
=E6=8A=84=E9=80=81: kaber@trash.net; netfilter-devel@vger.kernel.org; n=
etdev@vger.kernel.org; linux-kernel@vger.kernel.org; gfree.wind@gmail.c=
om
=E4=B8=BB=E9=A2=98: Re: =E7=AD=94=E5=A4=8D: [PATCH 1/1] netfilter: Add =
helper array register/unregister functions

On Wed, Jul 20, 2016 at 08:31:13AM +0800, =E9=AB=98=E5=B3=B0 wrote:
> Thanks Pablo.
>=20
> I had used the script "checkpatch.pl" to check the patch file.
> There was no indentation error reported.
>=20
> So could you give me more tails please or point one indentation error=
?
> Then I could correct it by myself next time.

I'm refering to this specifically:

static int function(int parameter1, struct another_structure *blah,
                    int parameter2, unsigned int parameter3);
                    ^

It is just a comestic issue, but we consistently align function paramet=
ers to the initial parens.

As I said, I have just manually fixed this here, so no problem, just ke=
ep this in mind for the next time.

Another observation: You should bump patch version numbering in each re=
vision and keep some history on its evolution.

The area after the patch separator --- and before diff stats is good to=
 place volatile information that is only meaningful to the review proce=
ss, I mean something like this:

  subsystem: Patch title.

  Patch description...

  Signed-off-by: Lucas Skywalker <trotacielos@blackstar.org>
  ---
  v3: Address comments from Chebakia on possible backward compatibility
      issues.
  v2: New parameter to control something.
  v1: Initial patch.

  include/net/netfilter/nf_tables.h |  25 ++-
  ...
  diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilte=
r/nf_tables.h

Thanks.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
