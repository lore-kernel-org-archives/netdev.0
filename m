From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: O/M flags against 2.6.0-test1
Date: Thu, 24 Jul 2003 10:26:21 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030724.102621.89190471.yoshfuji@linux-ipv6.org>
References: <20030724000705.4662df54.davem@redhat.com>
	<200307241402.SAA09143@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, krkumar@us.ibm.com, netdev@oss.sgi.com,
   yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307241402.SAA09143@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200307241402.SAA09143@dub.inr.ac.ru> (at Thu, 24 Jul 2003 18:02:35 +0400 (MSD)), kuznet@ms2.inr.ac.ru says:

> Maybe, struct is better, but I am inclined to think in this case it is wrong.
> It is going to be extended, so newly compiled applications will see
> truncated structs from older kernels and will have to do ugly job
> verifying validity of fields using some offsetof. In the case of array
> it is natural at least.

I'm not so sure about the "array," but anyway,
I don't think it is so ugly to use struct / offsetof.

--yoshfuji
