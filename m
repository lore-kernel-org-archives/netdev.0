From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/24] sysctl: cookie: add ctl_header_cookie
Date: Wed, 06 Apr 2011 12:53:44 -0700 (PDT)
Message-ID: <20110406.125344.179945750.davem@davemloft.net>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
	<cover.1301711868.git.lucian.grijincu@gmail.com>
	<059405611ddd6d70415081e0261805935e95d345.1301711868.git.lucian.grijincu@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, ebiederm@xmission.com, tavi@cs.pub.ro,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: lucian.grijincu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <059405611ddd6d70415081e0261805935e95d345.1301711868.git.lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Date: Sat,  2 Apr 2011 04:53:16 +0200

> @@ -205,6 +205,7 @@ static struct ctl_table_header root_table_header = {
>  	.ctl_entry = LIST_HEAD_INIT(sysctl_table_root.default_set.list),}},
>  	.root = &sysctl_table_root,
>  	.set = &sysctl_table_root.default_set,
> +	.ctl_header_cookie = NULL,
>  };

Such explicit setting of structure members to NULL in an assignment is
never necessary.  Please remove these, there were a few cases in this
patch.

Thanks.
