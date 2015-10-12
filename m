From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH v4 0/3] net: unix: fix use-after-free
Date: Mon, 12 Oct 2015 15:50:30 -0400
Message-ID: <561C0F06.90202@akamai.com>
References: <cover.1444363559.git.jbaron@akamai.com> <20151011.045557.2164838188213641141.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	minipli@googlemail.com, normalperson@yhbt.net,
	eric.dumazet@gmail.com, rweikusat@mobileactivedefense.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org,
	joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151011.045557.2164838188213641141.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/11/2015 07:55 AM, David Miller wrote:
> From: Jason Baron <jbaron@akamai.com>
> Date: Fri,  9 Oct 2015 00:15:59 -0400
>=20
>> These patches are against mainline, I can re-base to net-next, pleas=
e
>> let me know.
>>
>> They have been tested against: https://lkml.org/lkml/2015/9/13/195,
>> which causes the use-after-free quite quickly and here:
>> https://lkml.org/lkml/2015/10/2/693.
>=20

Hi,

> I'd like to understand how patches that don't even compile can be
> "tested"?
>=20
> net/unix/af_unix.c: In function =A1unix_dgram_writable=A2:
> net/unix/af_unix.c:2480:3: error: =A1other_full=A2 undeclared (first =
use in this function)
> net/unix/af_unix.c:2480:3: note: each undeclared identifier is report=
ed only once for each function it appears in
>=20
> Could you explain how that works, I'm having a hard time understandin=
g
> this?
>=20

Traveling this week, so responses a bit delayed.

Yes, I screwed up the posting. I had some outstanding code in my
local tree to make it compile, but I failed to refresh my patch series
with this outstanding code before mailing it out. So what I tested/buil=
t
was not quite what I mailed out.

As soon as I noticed this issue in patch 3/3 I re-posted it here:

http://marc.info/?l=3Dlinux-netdev&m=3D144440355808472&w=3D2

in an attempt to avoid this confusion. I'm happy to re-post the series
or whatever makes things easiest for you.

> Also please address Hannes's feedback, thanks.
>=20

I've replied directly to Hannes.

Thanks,

-Jason
