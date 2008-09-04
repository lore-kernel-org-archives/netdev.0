From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 11/38] netns ct: per-netns unconfirmed hash
Date: Thu, 04 Sep 2008 18:46:00 +0200
Message-ID: <48C010C8.9060808@trash.net>
References: <20080821220059.GK31136@x200.localdomain> <20080821224030.GB31601@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080821224030.GB31601@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

adobriyan@gmail.com wrote:
> What is unconfirmed connection in one netns can very well be confirmed
> in another.
> 

> @@ -10,5 +11,6 @@ struct netns_ct {
>  	unsigned int		expect_count;
>  	struct hlist_head	*expect_hash;
>  	int			expect_vmalloc;
> +	struct hlist_head	unconfirmed;
>  };

You could lay this out a bit better to avoid holes and move
the members only used rarely (like *_vmalloc) to the end.
