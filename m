From: Jon D Mason <jonmason@us.ibm.com>
Subject: Re: help on NAPI
Date: Sat, 24 Apr 2004 15:59:57 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF59723011.7AF60898-ON87256E80.007279F6-86256E80.0072E96E@us.ibm.com>
References: <20040424203301.76624.qmail@web60208.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040424203301.76624.qmail@web60208.mail.yahoo.com>
To: prashant s <sree_prash@yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Prashant,
NAPI performance gain is only when then packets are small in size. Withou=
t=20
NAPI, the number of interrupts per packet is high with small packets. Thi=
s=20
is mitigated by the polling functionality of NAPI, which handles the=20
packets without (err...relatively few) have to take interrupts.

It is better explained at=20
"http://lxr.linux.no/source/Documentation/networking/NAPI_HOWTO.txt?v=3D2=
.6.5"

With regard to better performance when using smaller ring sizes, this can=
=20
be attributed to a knock-on effect of cache aligning the buffers.  This=20
occurs on all adapters, and the optimal descriptor ring size differs=20
depending on your hardware.

Thanks,

Jon Mason                jonmason@us.ibm.com
Software Engineer        Phone:(512)838.4162
Linux eServer I/O        Fax:  (512)838.3509




prashant s <sree_prash@yahoo.com>
Sent by: netdev-bounce@oss.sgi.com
04/24/04 03:33 PM
=20
        To:     netdev@oss.sgi.com
        cc:=20
        Subject:        help on NAPI


sir,
 i have a doubt regarding the NAPI feature which is
introduced in 2.6.3 linux.
 i did not find any performance difference between the
NAPI driver (rtl 8139too 2.6.3 linux) and non NAPI
driver(rtl 8139too 2.4.20 linux) both of them showed
94Mbps(packet size of 1500bytes). The network card
which i used was a 100Mbps real tek card, and the
machine was a p 4. but when i reduced the DMA receive
ring size from 32K to 8k the NAPI driver showed 94Mbps
where as the non NAPI driver showed 72Mbps.
 why is this performance difference when the ring size
is reduced.
 waiting for your reply.

prashant


=20
=20
__________________________________
Do you Yahoo!?
Yahoo! Photos: High-quality 4x6 digital prints for 25=A2
http://photos.yahoo.com/ph/print_splash
