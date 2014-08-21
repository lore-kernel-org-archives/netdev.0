From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/1] netfilter/jump_label: use HAVE_JUMP_LABEL?
Date: Thu, 21 Aug 2014 14:11:32 +0200
Message-ID: <20140821121132.GA16498@breakpoint.cc>
References: <1408589568-27046-1-git-send-email-yizhouzhou@ict.ac.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jbaron@akamai.com,
	Zhouyi Zhou <yizhouzhou@ict.ac.cn>
To: Zhouyi Zhou <zhouzhouyi@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1408589568-27046-1-git-send-email-yizhouzhou@ict.ac.cn>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zhouyi Zhou <zhouzhouyi@gmail.com> wrote:
> 
> CONFIG_JUMP_LABEL doesn't ensure HAVE_JUMP_LABEL, if it
> is not the case use maintainers's own mutex to guard
> the modification of global values.

I don't understand this patch.

What is the problem you are fixing?

The intent is to only use static_key infrastructure
if user has enabled CONFIG_JUMP_LABEL.
