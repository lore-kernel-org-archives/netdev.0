From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IFA_MAX sets wrong in rtnetlink.h
Date: Fri, 28 May 2004 14:12:00 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040528.141200.564308976.yoshfuji@linux-ipv6.org>
References: <20040526135610.2ecaa96a.davem@redhat.com>
	<20040528.134802.953480362.yoshfuji@linux-ipv6.org>
	<20040527220756.7c41a55b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040527220756.7c41a55b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040527220756.7c41a55b.davem@redhat.com> (at Thu, 27 May 2004 22:07:56 -0700), "David S. Miller" <davem@redhat.com> says:

> On Fri, 28 May 2004 13:48:02 +0900 (JST)
> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:
> 
> > enum {
> >      :
> >      IFA_CACHEINFO,
> >      IFA_MULTICAST,   /* added */
> >      __IFA_MAX
> > };
> > 
> > #define IFA_MAX (__IFA_MAX - 1)
> 
> I like this last technique the best, one-line diffs :-)

Ok, I'll do this.

--yoshfuji
