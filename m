From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [net-next 10/12] bna: TX Queue Depth Fix
Date: Tue, 30 Aug 2011 21:34:39 -0700
Message-ID: <CAA93jw7OrqruzEu4EzEubqFdKpLrkPN9ksh5SSqU5pVcSCjgcw@mail.gmail.com>
References: <1314754068-31978-1-git-send-email-rmody@brocade.com>
	<1314754068-31978-11-git-send-email-rmody@brocade.com>
	<1314764670.2556.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rasesh Mody <rmody@brocade.com>, davem@davemloft.net,
	netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	Gurunatha Karaje <gkaraje@brocade.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41661 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931Ab1HaEek convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 00:34:40 -0400
Received: by iabu26 with SMTP id u26so348596iab.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 21:34:39 -0700 (PDT)
In-Reply-To: <1314764670.2556.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2011 at 9:24 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 30 ao=FBt 2011 =E0 18:27 -0700, Rasesh Mody a =E9crit :
>> sk_buff unmap_array grows greater than 65536 (x2) with Tx ring of 65=
536.
>> Reducing TXQ depth and safe(max) acking of Tx events to 32768 (same =
as Rx).
>> Add defines for TX and RX queue depths.

I was happy at the 'reducing txq depth' portion of the email, then I
saw the value it was reduced to.

thx for commenting thusly...

> BNAD_MAX_Q_DEPTH is now defined but not used.
>
> BTW, 32768 slots in a RX queue is insane.

As that is many lunar distances worth of buffering... Are they
expecting transmissions from mars?


--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://the-edge.blogspot.com
