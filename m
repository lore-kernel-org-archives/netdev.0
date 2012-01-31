From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] net: Disambiguate kernel message
Date: Tue, 31 Jan 2012 20:44:50 +0100
Message-ID: <20120131194450.GA8020@elte.hu>
References: <1327963304-24828-1-git-send-email-asharma@fb.com>
 <CAErSpo54KRJbWEQ0fB_kuGx0qRQKWpH9d3mN=dPdiNfWH+Dhww@mail.gmail.com>
 <20120131181554.GA24397@dev3310.snc6.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Glauber Costa <glommer@parallels.com>,
	christoph.paasch@uclouvain.be
To: Arun Sharma <asharma@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120131181554.GA24397@dev3310.snc6.facebook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Arun Sharma <asharma@fb.com> wrote:

> +				printk(KERN_INFO "TCP: too many orphaned "
>  				       "sockets\n");

> +				printk(KERN_INFO "TCP: out of memory. "
> +				       "Consider tuning tcp_mem\n");

> +			printk(KERN_INFO "TCP: out of memory. "
> +					 "Consider tuning tcp_mem\n");
> +		if (too_many_orphans && net_ratelimit())
> +			printk(KERN_INFO "TCP: too many orphaned sockets\n");

A small detail: please don't line break user-visible strings in 
mid sentence. Just keep the line long. Makes it much easier to 
search for the source of a kernel message:

   git grep "TCP: too many orphaned sockets"

Thanks,

	Ingo
