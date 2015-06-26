From: Jiri Slaby <jslaby@suse.com>
Subject: Re: please queue commit ac37e2515c1a for stable 3.12 - 3.18
Date: Fri, 26 Jun 2015 14:59:32 +0200
Message-ID: <558D4CB4.5070102@suse.com>
References: <20150604205403.GA24969@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>,
	Greg KH <gregkh@linuxfoundation.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: Michal Kubecek <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150604205403.GA24969@unicorn.suse.cz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/04/2015, 10:54 PM, Michal Kubecek wrote:
> Hello,
> 
> please queue mainline commit
> 
>   ac37e2515c1a ("xfrm: release dst_orig in case of error in xfrm_lookup()")
> 
> for stable branches 3.12, 3.14 and 3.18. It fixes a dst_entry reference
> leak introduced by commit
> 
>   f92ee61982d6 ("xfrm: Generate blackhole routes only from route lookup functions")
> 
> present in these branches (3.12 and 3.14 as a backport, 3.18 from
> mainline). The patch applies cleanly to all three and I tested that it
> fixes the issue in 3.12.

David, do you have any plans on taking the commit or should we apply it
directly?

thanks,
-- 
js
suse labs
