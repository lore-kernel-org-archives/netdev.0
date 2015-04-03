From: "Beshay, Joseph" <jdb109120@utdallas.edu>
Subject: Re: [PATCH] netem: Fixes byte backlog accounting for the first of two
 chained netem instances
Date: Fri, 3 Apr 2015 22:47:25 +0000
Message-ID: <6D4AABAE-EE8B-48E4-8C8D-90A3C0082270@utdallas.edu>
References: <DM2PR01MB511AE74EFA517D7A30CD41DD1F10@DM2PR01MB511.prod.exchangelabs.com>
 <CAPh34mdKV972Y7=BtddayCq3_PDZqYTXOq8eQk7SGZiQrbFvLQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netem@lists.linux-foundation.org" <netem@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outgoing.utdallas.edu ([129.110.100.201]:35516 "EHLO
	ip-relay-021.utdallas.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbDCW6f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 18:58:35 -0400
In-Reply-To: <CAPh34mdKV972Y7=BtddayCq3_PDZqYTXOq8eQk7SGZiQrbFvLQ@mail.gmail.com>
Content-Language: en-US
Content-ID: <10F5A94725AC5243832BAE45B0AF7DD3@prod.exchangelabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 3, 2015, at 5:21 PM, Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> On 3 April 2015 at 23:52, Beshay, Joseph <jdb109120@utdallas.edu> wro=
te:
>=20
>> +                       /* jbeshay: update byte backlog */
>> +                       qdisc_qstats_backlog_dec(sch, skb);
>=20
> Patch seems fine to me. Except the comment: that you update the qstat
> backlog is already noted in the function name - superfluous comment.
> That *you* fixed it will be saved in git. Think about it if we add
> these kinds of comments all over the place =85

Agreed. Should I resend the patch without the comments?
