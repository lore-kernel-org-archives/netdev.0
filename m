From: Suresh Krishnan <suresh.krishnan@ericsson.ca>
Subject: Re: [PATCH 2.6.9] address family not supported for sendmsg()
Date: Fri, 22 Oct 2004 20:07:01 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410222004070.18616-100000@localhost.localdomain>
References: <20041022.153137.99739029.yoshfuji@linux-ipv6.org>
Reply-To: Suresh Krishnan <suresh.krishnan@ericsson.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@davemloft.net, <suresh.krishnan@ericsson.ca>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20041022.153137.99739029.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave/Yoshifuji,
  I agree that the case you pointed out is tricky. I am fine with either 
EAFNOSUPPORT or EINVAL. But the POSIX and SUSv3 man pages specify EINVAL 
as a error only when the sum of iov_len values overflows ssize_t.

Thanks
Suresh

On Fri, 22 Oct 2004, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

>In article <20041022.153056.57690221.yoshfuji@linux-ipv6.org> (at Fri, 22 Oct 2004 15:30:56 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
>
>> This may be convered by EAFNOSUPPORT.
>              covered
>
>--yoshfuji
>
