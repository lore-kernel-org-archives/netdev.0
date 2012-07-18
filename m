From: Jim Rees <rees-63aXycvo3TyHXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH] SUNRPC: Prevent kernel stack corruption on long values
 of flush
Date: Wed, 18 Jul 2012 19:04:45 -0400
Message-ID: <20120718230445.GA6561@umich.edu>
References: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com>
 <20120718173913.GA1298@fieldses.org>
 <20120718200049.GA17964@umich.edu>
 <20120718210825.GA3145@fieldses.org>
 <50072BA7.6070205@gmail.com>
 <50072DEE.2000205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50072DEE.2000205-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sasha Levin wrote:

  > Learning from what happened in this specific case, there are actually 2 issues here:
  > 
  >  - Array size was constant and too small, which is solved by the patch above.
  >  - We were blindly trying to sprintf() into that array, this issue may pop back up if someone decides to change the format string forgetting to modify the array declaration.
  > 

The original patch changed the sprintf to snprintf, and that still seems
like a good idea.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
