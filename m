From: "Shigeo N" <shigeonx@gmail.com>
Subject: Re: XTP for 2.6.25
Date: Thu, 24 Apr 2008 20:26:44 +0900
Message-ID: <18b669d80804240426n230cdeax1408f923fbe6d619@mail.gmail.com>
References: <18b669d80804240314t7b2f6e4cpc9a9f2690c6d21b4@mail.gmail.com>
	 <20080424.033029.193698693.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:37591 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbYDXL0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 07:26:46 -0400
Received: by fg-out-1718.google.com with SMTP id l27so3035773fgb.17
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 04:26:44 -0700 (PDT)
In-Reply-To: <20080424.033029.193698693.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My motivation to implement XTP for Linux kernel is that XTP can be
better protocol than TCP in broad-band network, because XTP is free
from BD power limitation by separation of rate and flow control.

As far as I know, Packeteer's SkyX is only the product that implements
XTP. SkyX is mainly used for Satellite network which delay is too
long, but nowadays SkyX is used for broad-band network because XTP is
of great advantege to network delay in broad-band network.

Linux based network product is popular now, so adding XTP to Linux
kernel is useful for someone who develops Linux router, server and
etc, I think.

Thanks
Shigeo

On Thu, Apr 24, 2008 at 7:30 PM, David Miller <davem@davemloft.net> wrote:
> From: "Shigeo N" <shigeonx@gmail.com>
>  Date: Thu, 24 Apr 2008 19:14:38 +0900
>
>  [ netdev added to CC: ]
>
>
>
>  > I implemented Xpress Transport Protocol 4.0 for Linux kernel 2.6.25.
>  > Does anyone test it and give me feedback to enhance together ?
>  >
>  > I tested in the network where UDP throughput is 29Mbps, then TCP
>  > throughput was 13Mbps, but XTP's reached to 25Mbps.
>  >
>  > The source is here.
>  > <http://downloads.sourceforge.net/linux-xtp/linux-xtp.0.3.1.tar.gz?use_mirror=osdn>
>  >
>  > XTP specification is here.
>  > <http://www.packeteer.com/resources/prod-sol/XTP.pdf>
>  >
>  > Multicast function is not implemented yet.
>
>  Please discuss your work on netdev@vger.kernel.org, which is where
>  the Linux networking developers are listening.
>
>  Thank you.
>
