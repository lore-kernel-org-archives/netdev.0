From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 MIB:ipv6inetNetToMediaTable
Date: Fri, 16 Jan 2004 03:41:18 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116.034118.75621273.yoshfuji@linux-ipv6.org>
References: <OFE052816E.2064C677-ON88256E1C.0063EDA2@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mashirle@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: xma@us.ibm.com
In-Reply-To: <OFE052816E.2064C677-ON88256E1C.0063EDA2@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFE052816E.2064C677-ON88256E1C.0063EDA2@us.ibm.com> (at Thu, 15 Jan 2004 10:18:44 -0800), Shirley Ma <xma@us.ibm.com> says:

> Thanks. This is a bug fix for the update value (last change) to be a
> TimeStamp according to new IP MIBs. There is no confirm value in the new IP
> MIBs inetNetTomedia Entry, I don't know what's the confirm for, I still
> keep it, but change it to TimeStamp. Is there any application using these
> values right now? If you agree we can fix any applications reference these
> values.

ditto. application should obtain real MIB information using
information provided by kernel.
(If information is not enough, let kernel provide additional 
information.)

--yoshfuji
