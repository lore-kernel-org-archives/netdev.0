From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: Fix CWV being too strict on thin streams
Date: Wed, 23 Sep 2015 11:34:16 -0400
Message-ID: <CADVnQymZthkRV1UtxxptGiw06T7ZqTuPsqz6_Ks974F3QYbO0w@mail.gmail.com>
References: <1442619503-2282-1-git-send-email-bro.devel+kernel@gmail.com>
	<CADVnQy=PPe+-HP2Sm7qK6BUxbp-iKjERq7eXvR29+3R1yas7LA@mail.gmail.com>
	<CADVnQyn7683PoCo=PaP4CUF6CCNf+V7kCA8RdeZgZwk2SSddig@mail.gmail.com>
	<1895025.gntjczfsS0@garfield>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	Jonas Markussen <jonassm@ifi.uio.no>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>
To: =?UTF-8?Q?Bendik_R=C3=B8nning_Opstad?= <bro.devel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:35219 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755699AbbIWPeR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:34:17 -0400
Received: by obbzf10 with SMTP id zf10so36134321obb.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:34:16 -0700 (PDT)
In-Reply-To: <1895025.gntjczfsS0@garfield>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 10:46 AM, Bendik R=C3=B8nning Opstad
<bro.devel@gmail.com> wrote:
>> On Tue, Sep 22, 2015 at 2:02 PM, Neal Cardwell <ncardwell@google.com=
> wrote:
>> > More generally, my sense is that we should tweak the is_cwnd_limit=
ed code to
>> > shift from saying "set is_cwnd_limited to true iff the cwnd is kno=
wn to be
>> > limiting transmits" to saying "set is_cwnd_limited to true iff the=
 packets in
>> > flight fill the cwnd".
=2E..
> This fixes the identified problem and is a good fix as far as our tes=
ts show.
>
> Should I resend this as PATCH v2?

Yes, please send this latest patch as a v2, with an updated commit
message, to reflect the latest diagnosis/rationale.

Thanks!
neal
