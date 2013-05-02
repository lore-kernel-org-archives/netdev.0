From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [Patch net-next v7 4/6] vxlan: add ipv6 support
Date: Thu, 02 May 2013 14:45:36 +0200
Message-ID: <87sj25a6tr.fsf@nemi.mork.no>
References: <1367311395-15891-1-git-send-email-amwang@redhat.com>
	<1367311395-15891-5-git-send-email-amwang@redhat.com>
	<87r4hscr7s.fsf@nemi.mork.no> <1367313956.3216.18.camel@cr0>
	<87mwsgcnoy.fsf@nemi.mork.no> <1367481953.2415.29.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35532 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753608Ab3EBMqU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 08:46:20 -0400
In-Reply-To: <1367481953.2415.29.camel@cr0> (Cong Wang's message of "Thu, 02
	May 2013 16:05:53 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <amwang@redhat.com> writes:
> On Tue, 2013-04-30 at 12:33 +0200, Bj=C3=B8rn Mork wrote:
>>=20
>> Well, you have been told that your proposed new feature breaks IPv4
>> support with specific settings.  I do not think that you are speedin=
g
>> up
>> anything here by ignoring that fact.  On the contrary.=20
>
> It is obviously a corner case which is not deserved such a high prior=
ity
> (as high as a kernel panic or a compile error). bindv6only is default=
 to
> be 0, I even wasn't aware of such sysctl until David pointed it out.

It's a regression. Regressions trump new features. No need to argue
about the relative importance here.  Fix it.

> So, please give me a reason why we should let such a corner case bloc=
k
> the inclusion? I think there are still other such corner cases too (a=
nd
> maybe many), which neither you nor me are aware of.

Yes, I am pretty sure of that as well.  That's why I ask you to *test*
your code with assorted settings before resubmitting it.  I'm not going
to.

I note that you claim you are not an expert.  Neither am I.  And luckil=
y
I believe that is not required around here. Anyone can contribute, and
all contributions are very welcome.  At least that is the impression
I've got.

But only the experts can get away with limited testing. The less of an
expert you are, the more time you need to spend trying out every small
codepath you added using every possible input combination.  Doing
different combinations of buildtime and runtime IPv6 enable/disable is
an obvious requirement when you add code which has some sort of "if IPv=
6
is enabled" conditionals.  IMHO.



Bj=C3=B8rn
