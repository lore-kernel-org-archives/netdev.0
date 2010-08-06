From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 0/2] netfilter: xtables: xt_condition inclusion and
 change to u32
Date: Fri, 06 Aug 2010 15:54:25 +0200
Message-ID: <4C5C1411.7020709@trash.net>
References: <1281097308-1515-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jengelh@medozas.de, sameo@linux.intel.com
To: luciano.coelho@nokia.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1281097308-1515-1-git-send-email-luciano.coelho@nokia.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 06.08.2010 14:21, schrieb luciano.coelho@nokia.com:
> From: Luciano Coelho <luciano.coelho@nokia.com>
> 
> Hello,
> 
> Here v2 of the xt_condition patch, it contains some changes suggested by Jan.
> 
> When these patches get accepted, I'll send the implementation of the condition
> target, as discussed before.
> 
> In RFC v2 I've made a few changes as discussed in the review:
> 
>   * Removed per-netns module parameters
>   * Use par->net instead of current->nsproxy->net_ns
>   * Fix file-leak in procfs when exiting the netns
> 
> I didn't get any more comments in RFC v2, so I assume it is okay to send it for
> inclusion.

The merge window for networking patches is closed, I'm only taking
bugfixes at this time. Please resend once net-next opens up again.
