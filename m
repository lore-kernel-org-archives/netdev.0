From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: fix infinite cwnd in tcp_complete_cwr()
Date: Mon, 30 Apr 2012 13:45:40 -0400 (EDT)
Message-ID: <20120430.134540.610433288172120407.davem@davemloft.net>
References: <1335801618-31498-1-git-send-email-ycheng@google.com>
	<CADVnQymFjqqT__kCN-0vqz+jqBLez7aoQZ14KEV5=m=Ed=Nayw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ycheng@google.com, ilpo.jarvinen@helsinki.fi, nanditad@google.com,
	netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968Ab2D3Rpx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:45:53 -0400
In-Reply-To: <CADVnQymFjqqT__kCN-0vqz+jqBLez7aoQZ14KEV5=m=Ed=Nayw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Neal Cardwell <ncardwell@google.com>
Date: Mon, 30 Apr 2012 12:25:56 -0400

> On Mon, Apr 30, 2012 at 12:00 PM, Yuchung Cheng <ycheng@google.com> w=
rote:
>> When the cwnd reduction is done, ssthresh may be infinite
>> if TCP enters CWR via ECN or F-RTO. If cwnd is not undone, i.e.,
>> undo_marker is set, tcp_complete_cwr() falsely set cwnd to the
>> infinite ssthresh value. The correct operation is to keep cwnd
>> intact because it has been updated in ECN or F-RTO.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> ---
>> ChangeLog since v1:
>> =A0- Add snd_cwnd_stamp timestamping in CWR mode
>>
>> =A0net/ipv4/tcp_input.c | =A0 =A09 ++++++---
>> =A01 files changed, 6 insertions(+), 3 deletions(-)
>=20
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks.
