From: Jack Zhang <jack.zhang2011@gmail.com>
Subject: Re: can TCP socket send buffer be over used?
Date: Wed, 4 Aug 2010 02:03:45 -0600
Message-ID: <AANLkTikJvTvzuPhJ59RNcCGXPWP4EidaHx0=oUK8jjiy@mail.gmail.com>
References: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
	<alpine.DEB.1.10.1008040932030.19930@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:36808 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092Ab0HDIEH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 04:04:07 -0400
Received: by vws3 with SMTP id 3so3876588vws.19
        for <netdev@vger.kernel.org>; Wed, 04 Aug 2010 01:04:06 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.10.1008040932030.19930@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mikael,

Thanks for your reply. I'll definitely try that.

Quick question though... the link I use in my test does not have any
packet loss (it's a straight through cable between two PCs)... in this
case, would TCP congestion window size affect the result at all?

Thanks,
Jack

On 4 August 2010 01:33, Mikael Abrahamsson <swmike@swm.pp.se> wrote:
> On Tue, 3 Aug 2010, Jack Zhang wrote:
>
>> For example, when I set the send buffer size to 128 KB, i could get =
a
>> throughput up to 43 Mbps, which seems to be impossible as the (buffe=
r
>> size) / RTT is only 10 Mbps.
>
> Are you sure the buffer actually corresponds to the congestion window=
 TCP
> uses? I think you should use wireshark to dump the traffic and look i=
n the
> TCP headers of the packets to see what is actually going on on the wi=
re.
>
> --
> Mikael Abrahamsson =A0 =A0email: swmike@swm.pp.se
>
