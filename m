From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: strategy hander for net.ipv6.conf.*.forwarding
 (is Re: problem setting net.ipvX.conf.all.forwarding via sysctl() system
 call)
Date: Sat, 9 Aug 2003 14:44:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030809144416.181cbad1.davem@redhat.com>
References: <20030808093704.GA18131@wsx.ksp.sk>
	<20030808.185135.112441851.yoshfuji@linux-ipv6.org>
	<20030809010845.01ebcbe9.davem@redhat.com>
	<20030809.192158.47862071.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jan.oravec@6com.sk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030809.192158.47862071.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 09 Aug 2003 19:21:58 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> In article <20030809010845.01ebcbe9.davem@redhat.com> (at Sat, 9 Aug 2003 01:08:45 -0700), "David S. Miller" <davem@redhat.com> says:
> 
> > As I mentioned for the ipv4 forwarding sysctl bug fix,
> > if you will set table->data yourself you should return
> > > 0 (for example "1") from your strategy handler.
> :
> > Please fix this, thank you.
> 
> Here it is.

Patch applied, thank you.
