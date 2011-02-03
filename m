From: John Heffner <johnwheffner@gmail.com>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Thu, 3 Feb 2011 09:17:14 -0500
Message-ID: <AANLkTinEXYXeZs1=wVQRAPDQ53YY0ne9NgCZN3x1hbaA@mail.gmail.com>
References: <20110202.170750.229739784.davem@davemloft.net>
	<47859e9273bb0c1b2c32fc1adfa450ee@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org, therbert@google.com
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43237 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932156Ab1BCORQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 09:17:16 -0500
In-Reply-To: <47859e9273bb0c1b2c32fc1adfa450ee@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 3, 2011 at 9:00 AM, Hagen Paul Pfeifer <hagen@jauu.net> wro=
te:
>
> On Wed, 02 Feb 2011 17:07:50 -0800 (PST), David Miller wrote:
>
>> +/* TCP initial congestion window */
>> +#define TCP_INIT_CWND =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A010
>> +
>
> Davem, there is _no_ research how this huge IW will behave in environ=
ments
> with a small BDP. Belief it or not, but there are networks out there =
with a
> BDP similar to ~1980. Why for heaven's sake should this work in these
> environments? There are only _two_ extensive analysis one from Cherry=
 and
> and one from Ilpo. Both analysis focus on current mainstream BDP. I s=
tarted
> to setup a ns-2 environment but due to lack of time I am a little bit
> behind schedule. Anyway, why not make this a tunable per route knob s=
o that
> it is easier to fix things, e.g. set IW back to 3.


There's already a per-route tunable, right (RTAX_INITCWND)?

  -John
