From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/25] netfilter: nf_ct_helper: allow to disable
 automatic helper assignment
Date: Mon, 07 May 2012 21:34:18 -0400 (EDT)
Message-ID: <20120507.213418.1633667612399402231.davem@davemloft.net>
References: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
	<1336436539-5880-3-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336436539-5880-3-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue,  8 May 2012 02:21:56 +0200

> +	if (!net->ct.helper_sysctl_header) {
> +		printk(KERN_ERR "nf_conntrack_helper: can't register to sysctl.\n");
> +		goto out_register;
> +	}

Please use pr_err().

> +			printk(KERN_INFO "nf_conntrack: automatic helper "
> +				"assignment is deprecated. Please, read "
> +				"http://www.netfilter.org/news.html#2012-04-03\n");
> +			net->ct.auto_assign_helper_warned = true;

Please use pr_info().

Pointers to web sites to explain a problem is absolutely not
appropriate in kernel log messages, nor commit messages.

Either add a document to the kernel tree, or explain things
fully both in the kernel log message and the commit message.
