From: Shirley Ma <xma@us.ibm.com>
Subject: Re: [PATCH] Implementation for IPv6 MIB:ipv6AddressTable
Date: Tue, 7 Oct 2003 10:11:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFB064680A.7B686FB0-ON87256DB8.005E1987@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, mashirle@us.ibm.com,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





Yes. Yoshifuji is right.The timeStamp should be

-- hundredths of seconds since an epoch
TimeTicks ::=
    [APPLICATION 3]
        IMPLICIT INTEGER (0..4294967295)

I will modify the patch, and resubmit it against Linux-2.6.0-test6-bk8
again.

Thanks
Shirley Ma
IBM Linux Technology Center
15300 SW Koll Parkway
Beaverton, OR 97006-6063
Phone: (503) 578-7638
FAX:      (503) 578-3228



YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>@oss.sgi.com on
10/07/2003 04:35:18 AM

Sent by:    netdev-bounce@oss.sgi.com


To:    davem@redhat.com
cc:    kuznet@ms2.inr.ac.ru, mashirle@us.ltcfwd.linux.ibm.com,
       netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Subject:    Re: [PATCH] Implementation for IPv6 MIB:ipv6AddressTable


In article <20031007041246.13aa0391.davem@redhat.com> (at Tue, 7 Oct 2003
04:12:46 -0700), "David S. Miller" <davem@redhat.com> says:

> On Tue, 7 Oct 2003 15:16:20 +0400 (MSD)
> kuznet@ms2.inr.ac.ru wrote:
>
> > Actually, this does not depend on our implementation. If people
implement
> > a MIB, required precision of these times is prescribed in the rfc.
> > And this is definitely not jiffies.
>
> Right, Shirley what is it?

The type is TimeTicks (RFC2578) via TimeStamp (RFC2579).
Thus, uint32_t counter in 1/100 sec. unit.

--yoshfuji
