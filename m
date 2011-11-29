From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 09:51:43 +0100
Message-ID: <CAA93jw6bvzASrtvjhKL+haZb0VEPvQQD0guf7aBTPxJbxydEAg@mail.gmail.com>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	<CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	<1322550138.2970.70.camel@edumazet-laptop>
	<4ED4885F.8060309@intel.com>
	<CAA93jw7prPymGuWdn0pgHXL81g19opm2=-T4msy-b_s2MJ9=Jw@mail.gmail.com>
	<1322556234.2970.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Tom Herbert <therbert@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:48956 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116Ab1K2Ivo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 03:51:44 -0500
Received: by ggnr5 with SMTP id r5so6160712ggn.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 00:51:44 -0800 (PST)
In-Reply-To: <1322556234.2970.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 9:43 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 29 novembre 2011 =E0 09:37 +0100, Dave Taht a =E9crit :
>> On Tue, Nov 29, 2011 at 8:23 AM, John Fastabend
>> <john.r.fastabend@intel.com> wrote:
>> >
>> > I wonder if we should consider enabling TSO/GSO per queue or per t=
raffic
>> > class on devices that support this. At least in devices that suppo=
rt
>> > multiple traffic classes it seems to be a common usage case to put=
 bulk
>> > storage traffic (iSCSI) on a traffic class and low latency traffic=
 on a
>> > separate traffic class, VoIP for example.
>>
>>
>> VOIP is a drop in the bucket.
>>
>> Turning TSO off on TCP exiting the datacenter (or more specifically)=
,
>> destined anywhere there is potential tx/rx bandwidth disparity
>> would be goooooood.
>>
>
> If your cpu is fast enough (and they are most of the time), this make=
s
> no difference at all.
>
> Instead of consuming 3% of cpu with TSO, you'll consume 10% or 15% an=
d
> no difference seen on the wire.

Perhaps I don't understand the gross effects of TSO very well, but if y=
ou have
100 streams coming from a server, destined to X different destinations,
and you FQ to each on a per packet basis, you end up impacting the down=
stream
receive buffers throughout much less than if you send each stream as a =
burst.

>
> Really, if you want to avoid bursts, TSO has litle to do with them.

If I'm misunderstanding the downstream effects of TSO, I stand correcte=
d.

>
>
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
