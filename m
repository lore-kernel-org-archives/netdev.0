From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: [PATCH] IPv6, sit: set prefix length 64 for link-local addresses
Date: Sun, 5 Oct 2003 14:35:36 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031005123536.GA24311@wsx.ksp.sk>
References: <20030926175405.GA31498@wsx.ksp.sk> <20030926201953.3dfc67bf.davem@redhat.com> <20031005091844.GA23676@wsx.ksp.sk> <20031005.212846.50858920.yoshfuji@linux-ipv6.org>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20031005.212846.50858920.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 05, 2003 at 09:28:46PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> In article <20031005091844.GA23676@wsx.ksp.sk> (at Sun, 5 Oct 2003 11:18:45 +0200), Jan Oravec <jan.oravec@6com.sk> says:
> 
> > The function sit_add_v4_addrs() calls ipv6_add_addr() with plen 64 if local
> > endpoint of tunnel is not configured, so I do not see a reason to set plen
> > to 128 if local endpoint is configured.
> 
> This patch seems logically wrong.

You mean the text above (current kernel implementation) or the patch which
sets it to 64 in both cases? If the patch is wrong, can you explain why?


Jan
