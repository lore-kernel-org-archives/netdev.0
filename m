From: "tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] iwlwifi: dvm: convert create_singlethread_workqueue() to
 alloc_workqueue()
Date: Thu, 17 Mar 2016 06:18:11 -0700
Message-ID: <20160317131811.GO21104@mtj.duckdns.org>
References: <1458218246-18807-1-git-send-email-eraretuya@gmail.com>
 <0BA3FCBA62E2DC44AF3030971E174FB32EA7C435@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eva Rachel Retuya <eraretuya-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"outreachy-kernel-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org"
	<outreachy-kernel-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	"Berg, Johannes" <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linuxwifi <linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32EA7C435-Jy8z56yoSI9wl47ZQwxUxrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

On Thu, Mar 17, 2016 at 12:43:35PM +0000, Grumbach, Emmanuel wrote:
> > 
> > Use alloc_workqueue() to allocate the workqueue instead of
> > create_singlethread_workqueue() since the latter is deprecated and is
> > scheduled
> > for removal.
> 
> I can't see any indication of that in the code of workqueue.
> Can you share details about that?

create*_workqueue()'s have been deprecated and replaced by
alloc*_workqueue()'s for some years now.  I probably should note that
in the header file.

Thanks.

-- 
tejun
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
