From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Subject: Re: [PATCH 9/9] netfilter: implement xt_cgroup cgroup2 path match
Date: Mon, 23 Nov 2015 13:43:01 +0100
Message-ID: <565309D5.80707@bmw-carit.de>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <1448122441-9335-10-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <kernel-team-b10kYP2dOMg@public.gmane.org>,
	<ninasc-b10kYP2dOMg@public.gmane.org>, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>, <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	<kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org>, <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	<nhorman-2XuSBdqkA4SvXiR4WA35Jg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1448122441-9335-10-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

On 11/21/2015 05:14 PM, Tejun Heo wrote:> +static int
> cgroup_mt_check_v1(const struct xt_mtchk_param *par)
> +{
> +	struct xt_cgroup_info_v1 *info = par->matchinfo;
> +	struct cgroup *cgrp;
> +
> +	if ((info->invert_path & ~1) || (info->invert_classid & ~1))
> +		return -EINVAL;

The checks below use pr_info() in case the configuration is not valid.
Is this missing here on purpose?

I have tested it slightly and it seems to work (also on an older
kernel). I don't know if that qualifies it for a Tested-by but at least
Acked-by should do the trick:

Tested-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Acked-by: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>

cheers,
daniel
