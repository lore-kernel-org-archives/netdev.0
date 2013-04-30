From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [Patch net-next v7 4/6] vxlan: add ipv6 support
Date: Tue, 30 Apr 2013 12:33:49 +0200
Message-ID: <87mwsgcnoy.fsf@nemi.mork.no>
References: <1367311395-15891-1-git-send-email-amwang@redhat.com>
	<1367311395-15891-5-git-send-email-amwang@redhat.com>
	<87r4hscr7s.fsf@nemi.mork.no> <1367313956.3216.18.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54328 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932142Ab3D3KeN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 06:34:13 -0400
In-Reply-To: <1367313956.3216.18.camel@cr0> (Cong Wang's message of "Tue, 30
	Apr 2013 17:25:56 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:
> On Tue, 2013-04-30 at 11:17 +0200, Bj=C3=B8rn Mork wrote:
>> Please take your time to clean up your todo-list and *test* the resu=
lt
>> with different runtime and buildtime settings. There is no need to r=
ush
>> this, and people may get tired of looking at the same shortcomings o=
ver
>> and over again.
>>=20
>
> So, why do you expect it is perfect?

No, I do not expect anything to be perfect.  But I do expect that you,
when adding IPv6 support, don't *knowingly* break existing IPv4
installations.

> It is extremely normal that a new feature is not perfect initially, a=
nd
> takes more time to make it perfect. If you need a real example, netli=
nk
> mmap is exactly one, the initial version merged into net-next even
> doesn't compile for some case.
>
> And, why do you want to rely on me to fix them all?
>
> I am *not* at all an expert on IPv6. If this patchset could be merged
> early, many other IPv6 expert can help me to fix the rest issues.

Well, you have been told that your proposed new feature breaks IPv4
support with specific settings.  I do not think that you are speeding u=
p
anything here by ignoring that fact.  On the contrary.

And net-next was already closed for new features when you sent the last
version, so I really, really do not understand why you are in such a
hurry.  Sorry.

Note that I'm neither an expert or anything else here.  This is just my
personal view. Feel free to ignore it, but please think about it for a
second or two first.



Bj=C3=B8rn
