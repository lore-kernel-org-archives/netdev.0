From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC,PATCH] remove IPV6_AUTHHDR socket option / ancillary data
Date: Sun, 8 Feb 2004 12:58:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208125818.02eba2f5.davem@redhat.com>
References: <20040208.141117.116936870.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040208.141117.116936870.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 08 Feb 2004 14:11:17 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> AH is now handled by the XFRM engine.
> IPV6_AUTHHDR socket option / ancillary data are deprecated.
> 
> For sender side, it is very difficult (or even almost impossible) to
> create "correct" AH in userspace.
> For receiver side, none set opt->auth and user space application
> never get authentication data.
> 
> IPV6_AUTHHDR is very Linux-specific and applications which use
> these feature are not portable at all.

I totally agree, I didn't even know this broken thing existed
to be honest.

Let's kill this now.

Patch applied, thanks Yoshfuji.
