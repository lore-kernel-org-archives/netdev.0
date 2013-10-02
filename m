From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH net-next] net:drivers/net: Miscellaneous conversions to ETH_ALEN
Date: Wed, 2 Oct 2013 10:44:32 -0700
Message-ID: <CAB=NE6V3b4+B06hzPjhww52wp1FHho3329cP25=5Cy833bysvg@mail.gmail.com>
References: <1380679480.2081.24.camel@joe-AO722> <87k3hw469z.fsf@kamboji.qca.qualcomm.com>
 <1380696054.2081.35.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
	netdev <netdev@vger.kernel.org>, ath10k@lists.infradead.org
To: Joe Perches <joe@perches.com>, Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:60011 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566Ab3JBRoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 13:44:54 -0400
Received: by mail-la0-f50.google.com with SMTP id gx14so938084lab.23
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 10:44:52 -0700 (PDT)
In-Reply-To: <1380696054.2081.35.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 1, 2013 at 11:40 PM, Joe Perches <joe@perches.com> wrote:
> Please include netdev.  (cc'd)
>
>> Joe Perches <joe@perches.com> writes:
>>
>> > Convert the memset/memcpy uses of 6 to ETH_ALEN
>> > where appropriate.
>
>> > Signed-off-by: Joe Perches <joe@perches.com>

I think these sorts of patches are good -- but once applied it'd be
good if we can get the SmPL grammar expressed for it and then have
developers / maintainers regularly doing:

make coccicheck MODE=patch M=path > path-cocci.patch

Unfortunately right now MODE=patch takes about 3 1/2 minutes for
ath9k, MODE=org takes ~10 minutes for ath9k (17 minutes for all of
ath/), and MODE=context takes ~8 minutes on ath9k -- I do believe its
a bit unreasonable to expect patch submitters to use this, but
certainly great practice. Some of the time differences on the reports
can be explained by the fact that some SmPL will only be used for some
modes.

Even though it takes a while right now it'd be great practice to use
coccicheck to prevent these type of changes from going in again,
things that checkpatch.pl won't be able to catch.

  Luis
