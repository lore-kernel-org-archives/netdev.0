From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] update ip-sysctl.txt documentation
Date: Tue, 06 Jan 2015 17:40:39 -0500 (EST)
Message-ID: <20150106.174039.783537681001060022.davem@davemloft.net>
References: <1420583625-32414-1-git-send-email-ani@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, edumazet@google.com, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, P@draigbrady.com,
	netdev@vger.kernel.org, fruggeri@arista.com
To: ani@arista.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1420583625-32414-1-git-send-email-ani@arista.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ani Sinha <ani@arista.com>
Date: Tue,  6 Jan 2015 14:33:45 -0800

> @@ -64,8 +64,10 @@ fwmark_reflect - BOOLEAN
>  	Default: 0
>  
>  route/max_size - INTEGER
> -	Maximum number of routes allowed in the kernel.  Increase
> -	this when using large numbers of interfaces and/or routes.
> +        Post linux kernel 3.6, this is depricated for ipv4 as route cache is no
> +        longer used. For ipv6, this is used to limit the maximum number of ipv6
> +        routes allowed in the kernel.  Increase this when using large numbers of
> +        interfaces and/or routes.

Please do not change the TABs into sequenes of space characters.
