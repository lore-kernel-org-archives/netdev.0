From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: inappropriate usage of inet{,6}_sk()
Date: Tue, 28 Oct 2003 03:08:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031028030825.70843a6a.davem@redhat.com>
References: <20031027.232700.97608602.yoshfuji@linux-ipv6.org>
	<20031028010418.6e8960a8.davem@redhat.com>
	<20031028.200855.55272006.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031028.200855.55272006.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 28 Oct 2003 20:08:55 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> In article <20031028010418.6e8960a8.davem@redhat.com> (at Tue, 28 Oct 2003 01:04:18 -0800), "David S. Miller" <davem@redhat.com> says:
> 
> > Cannot reference inet6_sk() or tw->tw_v6_rcv_saddr outside of
> > CONFIG_IPV6 || CONFIG_IPV6_MODULE since these things do not exist when
> > those configs are both disabled.
> 
> Oh... Here's revised patch.

Applied, thank you Yoshfuji.
