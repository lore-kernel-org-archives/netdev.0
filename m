From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: =?utf-8?B?562U5aSNOiBbUEFUQ0ggMS8x?= =?utf-8?Q?=5D?= netfilter:
 Add helper array register/unregister functions
Date: Wed, 20 Jul 2016 10:50:18 +0200
Message-ID: <20160720085018.GD1336@salvia>
References: <1468813163-18139-1-git-send-email-fgao@ikuai8.com>
 <20160719181250.GA6116@salvia>
 <014e01d1e21e$062884b0$12798e10$@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	gfree.wind@gmail.com
To: =?utf-8?B?6auY5bOw?= <fgao@ikuai8.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <014e01d1e21e$062884b0$12798e10$@ikuai8.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

It is just a comestic issue, but we consistently align function
parameters to the initial parens.

As I said, I have just manually fixed this here, so no problem, just
keep this in mind for the next time.

Another observation: You should bump patch version numbering in each
revision and keep some history on its evolution.

The area after the patch separator --- and before diff stats is good
to place volatile information that is only meaningful to the review
process, I mean something like this:

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
