From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bluetooth: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Wed, 13 Mar 2013 05:31:45 -0400 (EDT)
Message-ID: <20130313.053145.2200448840921851390.davem@davemloft.net>
References: <1363111995-26866-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, marcel@holtmann.org,
	gustavo@padovan.org, johan.hedberg@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: silviupopescu1990@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363111995-26866-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Date: Tue, 12 Mar 2013 20:13:15 +0200

> @@ -590,10 +590,7 @@ int __init bt_sysfs_init(void)
>  	bt_debugfs = debugfs_create_dir("bluetooth", NULL);
>  
>  	bt_class = class_create(THIS_MODULE, "bluetooth");
> -	if (IS_ERR(bt_class))
> -		return PTR_ERR(bt_class);
> -
> -	return 0;
> +	return PTR_RET(bt_class)

Don't bother submitting patches you aren't even going to try
to compile.

I'm rejecting all of your current submissions.  Resubmit them
when you feel like typing 'make' from time to time.
