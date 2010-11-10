From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 0/9] treewide: convert vprintk uses to %pV
Date: Wed, 10 Nov 2010 15:01:23 -0800
Message-ID: <1289430083.15905.106.camel@Joe-Laptop>
References: <cover.1289348757.git.joe@perches.com>
	 <AANLkTinhcbdm8YQOrFVdONODo6K6PcxHYtx5vqnap_3T@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cluster-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-nilfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nilfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTinhcbdm8YQOrFVdONODo6K6PcxHYtx5vqnap_3T-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nilfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-11-10 at 14:48 -0800, Luis R. Rodriguez wrote:
> When was this added upstream BTW? I ask for backport considerations.

commit 7db6f5fb65a82af03229eef104dc9899c5eecf33
Author: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date:   Sun Jun 27 01:02:33 2010 +0000

    vsprintf: Recursive vsnprintf: Add "%pV", struct va_format
    
    Add the ability to print a format and va_list from a structure pointer
    
    Allows __dev_printk to be implemented as a single printk while
    minimizing string space duplication.
    
    %pV should not be used without some mechanism to verify the
    format and argument use ala __attribute__(format (printf(...))).
    
    Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
    Acked-by: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
    Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>


--
To unsubscribe from this list: send the line "unsubscribe linux-nilfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
