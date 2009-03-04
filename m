From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC][PATCH] neigh: Allow for user space users of the
 neighbour table
Date: Wed, 04 Mar 2009 00:03:24 -0800 (PST)
Message-ID: <20090304.000324.111056346.davem@davemloft.net>
References: <m11vtshn74.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gk-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m11vtshn74.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Date: Fri, 20 Feb 2009 12:23:43 -0800

> 
> Currently it is possible to do just about everything with the arp table
> from user space except treat an entry like you are using it.  To that end
> implement and a flag NTF_USE that when set in a netwlink update request
> treats the neighbour table entry like the kernel does on the output path.
> 
> This allows user space applications to share the kernel's arp cache.
> 
> Signed-off-by: Eric Biederman <ebiederm-BGArkANP9klv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>

Ok, no objections from me.

I'll apply this to net-next-2.6, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
