From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Suggestion] net-ipv6: format %8s change to %16s in
 rt6_info_route function of route.c
Date: Thu, 01 Nov 2012 10:01:22 +0100
Message-ID: <1351760482.32673.913.camel@edumazet-glaptop>
References: <50921A92.8000809@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50921A92.8000809@asianux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-11-01 at 14:45 +0800, Chen Gang wrote:
> Hello:
> 
> 1) For Public Kernel:
> 
>    A) in rt6_info_route function of net/ipv6/route.c
> 
>    B) the length of rt->rt6i_dev->name is 16 (IFNAMSIZ)
> 
>    C) using %16s is better than %8s (it will be more "beautiful")
>       (also suggest to delete RT6_INFO_LEN, it is useless for ever)
> 
> 
> 
> 2) For Red Hat RHEL5:
> 
>    A) in rt6_info_route function of net/ipv6/route.c
> 
>    B) the length of rt->rt6i_dev->name is 16 (IFNAMSIZ)
> 
>    C) for RT6_INFO_LEN is still useful, so it is an correctness issue.
> 
>    the relative patch for RHEL5 is below:

Hi Chen

Thats a good suggestion indeed.

Networking patches should be sent to netdev@vger.kernel.org (added in
CC)

This list only cares about recent generic kernels, not RedHat ones.

If you want to provide a patch, please base it on David Miller net-next
[1] tree, and make it official (read Documentation/SubmittingPatches for
general advices)

By the way, the %8s should be replaced by %s, there is no need to make
/proc/net/ipv6_route 'beautiful'. In the past, it was *needed* because
each line had to be of a given length, but its not anymore the case.

Thanks

[1] :
http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git;a=summary
