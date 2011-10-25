From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] net: make bonding slaves honour master's skb->priority
Date: Tue, 25 Oct 2011 09:45:35 -0700
Message-ID: <7147.1319561135@death>
References: <1319517660-22085-1-git-send-email-zenczykowski@gmail.com> <1319519056-21677-1-git-send-email-zenczykowski@gmail.com> <20111025110808.27db8487@asterix.rh> <CANP3RGeMbVFf6oL3+9i8h43q1ycdzcA47rNfzeyLWpi8M8ZV5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Flavio Leitner <fbl@redhat.com>, netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3FUTF-8=3FQ=3FMaciej=5F=3DC5=3DBBenczykowski=3F=3D?=
	<zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:41136 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab1JYQts convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 12:49:48 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 25 Oct 2011 10:47:13 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9PGjgAd078304
	for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 10:45:42 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9PGjf6o011112
	for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 10:45:41 -0600
In-reply-to: <CANP3RGeMbVFf6oL3+9i8h43q1ycdzcA47rNfzeyLWpi8M8ZV5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

>> I tripped on it few times and never understood why we
>> were fixing the priority at this point.
>> thanks,
>
>It looks like ancient code, going all the way back to something like
>Linux 2.4.14 (if I recall my git blame session correctly).
>I can't think of a good reason for this...

	I believe this line goes back to the beginning, prior to git or
bk.  The skb->priority probably meant something different than it does
today.

	In any event, I'm fine with the code change.  There's still no
actual log message, but if Davem is ok with that I'm ok with it, given
the trivial nature of the change.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
