From: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
Subject: [PATCH -next 0/4] cgroup: bpf: cgroup2 membership test on skb
Date: Tue, 21 Jun 2016 17:23:18 -0700
Message-ID: <1466555002-1316296-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <kernel-team-b10kYP2dOMg@public.gmane.org>
To: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series is to implement a bpf-way to
check the cgroup2 membership of a skb (sk_buff).

It is similar to the feature added in netfilter:
c38c4597e4bf ("netfilter: implement xt_cgroup cgroup2 path match")

The current target is the tc-like usage.
