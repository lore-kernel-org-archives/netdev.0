From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IFA_MAX sets wrong in rtnetlink.h
Date: Thu, 27 May 2004 22:07:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040527220756.7c41a55b.davem@redhat.com>
References: <200405261319.55787.mashirle@us.ibm.com>
	<200405261350.39088.mashirle@us.ibm.com>
	<20040526135610.2ecaa96a.davem@redhat.com>
	<20040528.134802.953480362.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040528.134802.953480362.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 May 2004 13:48:02 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> enum {
>      :
>      IFA_CACHEINFO,
>      IFA_MULTICAST,   /* added */
>      __IFA_MAX
> };
> 
> #define IFA_MAX (__IFA_MAX - 1)

I like this last technique the best, one-line diffs :-)
