From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] Traffic control cgroups subsystem
Date: Mon, 21 Jul 2008 16:04:04 +0200
Message-ID: <48849754.7000807@trash.net>
References: <Pine.LNX.4.64.0807181425270.18212@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	menage@google.com
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754966AbYGUOEX@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0807181425270.18212@ranjit.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ranjit Manomohan wrote:
> This patch adds a traffic control cgroup subsystem that is used
> to tag all packets originating from tasks in this cgroup with a
> specific identifier (tc_classid).
> 
> +#ifdef CONFIG_CGROUP_TC
> +    skb->cgroup_classid = sk->sk_cgroup_classid;
> +#endif

Please wrap this in an inline function so you don't have to
put the #ifdefs everywhere.
