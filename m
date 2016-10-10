From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Accelerated receive flow steering (aRFS) for UDP
Date: Mon, 10 Oct 2016 09:08:27 -0700
Message-ID: <ed0f723c-5e66-6d23-086d-71744570700a@hpe.com>
References: <SN1PR07MB244706470867A923CF0FAF6589C60@SN1PR07MB2447.namprd07.prod.outlook.com>
 <1475883496.28155.270.camel@edumazet-glaptop3.roam.corp.google.com>
 <SN1PR07MB2447ED02140770F0B46967D589D90@SN1PR07MB2447.namprd07.prod.outlook.com>
 <1476033293.28155.273.camel@edumazet-glaptop3.roam.corp.google.com>
 <SN1PR07MB2447D70FD02730AFCEA410A089D80@SN1PR07MB2447.namprd07.prod.outlook.com>
 <1476052402.28155.277.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "maorg@mellanox.com" <maorg@mellanox.com>,
        "tom@herbertland.com" <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        "Chopra, Manish" <Manish.Chopra@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2353.austin.hpe.com ([15.233.44.26]:46153 "EHLO
        g2t2353.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753243AbcJJQI3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2016 12:08:29 -0400
In-Reply-To: <1476052402.28155.277.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2016 03:33 PM, Eric Dumazet wrote:
> OK, I am adding/CC Rick Jones, netperf author, since it seems a netperf
> bug, not a kernel one.
>
> I believe I already mentioned fact that "UDP_STREAM -- -N" was not doing
> a connect() on the receiver side.

I can confirm that the receive side of the netperf omni path isn't 
trying to connect UDP datagrams.  I will see what I can put together.

happy benchmarking,

rick jones
rick.jones2@hpe.com
