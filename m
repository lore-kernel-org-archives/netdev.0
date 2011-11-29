From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Tue, 29 Nov 2011 09:37:45 +0100
Message-ID: <CAA93jw7prPymGuWdn0pgHXL81g19opm2=-T4msy-b_s2MJ9=Jw@mail.gmail.com>
References: <alpine.DEB.2.00.1111281825200.25622@pokey.mtv.corp.google.com>
	<CAA93jw7P=7YMOS_sMQWBJx0UJ6e+xw4e_hw8szNiVTOjGNwukw@mail.gmail.com>
	<1322550138.2970.70.camel@edumazet-laptop>
	<4ED4885F.8060309@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:60907 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836Ab1K2Ihq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 03:37:46 -0500
Received: by yenl6 with SMTP id l6so3790324yen.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 00:37:45 -0800 (PST)
In-Reply-To: <4ED4885F.8060309@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 8:23 AM, John Fastabend
<john.r.fastabend@intel.com> wrote:
>
> I wonder if we should consider enabling TSO/GSO per queue or per traf=
fic
> class on devices that support this. At least in devices that support
> multiple traffic classes it seems to be a common usage case to put bu=
lk
> storage traffic (iSCSI) on a traffic class and low latency traffic on=
 a
> separate traffic class, VoIP for example.


VOIP is a drop in the bucket.

Turning TSO off on TCP exiting the datacenter (or more specifically),
destined anywhere there is potential tx/rx bandwidth disparity
would be goooooood.


>
> John.



--
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
