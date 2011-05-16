From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT return
Date: Mon, 16 May 2011 17:01:50 +0200
Message-ID: <BANLkTi=Q_RrGgw0H=OeNeJ4JkkCgyYckFA@mail.gmail.com>
References: <20110516121339.GA1094@rere.qmqm.pl> <1305335142.2851.70.camel@bwh-desktop>
 <20110514103539.GA5214@rere.qmqm.pl> <1305513923.19966.20.camel@localhost>
 <20110516132807.1A89F13A6A@rere.qmqm.pl> <1305553066.19966.32.camel@localhost>
 <20110516142340.GA2980@rere.qmqm.pl> <1305557597.2885.5.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:38114 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755748Ab1EPPCM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 11:02:12 -0400
Received: by qyg14 with SMTP id 14so2668641qyg.19
        for <netdev@vger.kernel.org>; Mon, 16 May 2011 08:02:11 -0700 (PDT)
In-Reply-To: <1305557597.2885.5.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 16 maja 2011 16:53 u=BFytkownik Ben Hutchings
<bhutchings@solarflare.com> napisa=B3:
> On Mon, 2011-05-16 at 16:23 +0200, Micha=B3 Miros=B3aw wrote:
>> On Mon, May 16, 2011 at 02:37:46PM +0100, Ben Hutchings wrote:
>> > On Mon, 2011-05-16 at 15:28 +0200, Micha=B3 Miros=B3aw wrote:
>> > > Remove NETIF_F_COMPAT since it's redundant and will be unused af=
ter
>> > > all drivers are converted to fix/set_features.
>> > >
>> > > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
>> > > ---
>> > >
>> > > For net as we don't want to have ETHTOOL_F_COMPAT hit stable rel=
ease.
>> > [...]
>> > ETHTOOL_F_WISH means that the requested features could not all be
>> > enabled, *but are remembered*. =A0ETHTOOL_F_COMPAT means they were=
 not
>> > remembered.
>>
>> Hmm. So, lets just revert 39fc0ce5710c53bad14aaba1a789eec810c556f9
>> (net: Implement SFEATURES compatibility for not updated drivers).
> That's also problematic because it means we can't make any use of the
> 'available' masks from ETHTOOL_GFEATURES.
>
> The patch I sent is actually tested with a modified ethtool. =A0The
> fallback works. =A0I don't think you've tested whether any of your
> proposals can actually practically be used by ethtool.

You haven't posted the updates to ethtool to netdev. I just work blind =
here.

=46or now I use userspace version I sent along some of the first series
of the conversion patches. It actually makes it easier to use if the
compatibility handling stays in kernel (doesn't care about
ETHTOOL_F_COMPAT, BTW).

Best Regards,
Micha=B3 Miros=B3aw
