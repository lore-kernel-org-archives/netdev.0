From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/2] bpf: allow eBPF access skb fields
Date: Sun, 15 Mar 2015 22:03:27 -0400 (EDT)
Message-ID: <20150315.220327.1395688557673633308.davem@davemloft.net>
References: <1426273064-4837-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1426273064-4837-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Date: Fri, 13 Mar 2015 11:57:41 -0700

> Hi All,
> 
> V1->V2:
> - refactored field access converter into common helper convert_skb_access()
>   used in both classic and extended BPF
> - added missing build_bug_on for field 'len'
> - added comment to uapi/linux/bpf.h as suggested by Daniel
> - dropped exposing 'ifindex' field for now
> 
> classic BPF has a way to access skb fields, whereas extended BPF didn't.
> This patch introduces this ability.

I've applied this series.

I guess you guys can argue forever where the SKB offset validation
checks should be, and if you decide to do things differently than
it is done in this series just send me a followup patch.

Thanks.
