From: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Subject: Re: [PATCH 7/7] initdev:kernel:Await block device discovery
Date: Tue, 09 Jun 2009 00:55:01 +0200
Message-ID: <4A2D96C5.2080604@s5r6.in-berlin.de>
References: <20090606023416.GA5798@cuplxvomd02.corp.sa.net> <4A2A3F36.4070408@s5r6.in-berlin.de> <20090608223019.GC22222@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090608223019.GC22222-CFZJ1or75eBPWxJt6d6B6bQa8qPdvLwY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David VomLehn wrote:
> On Sat, Jun 06, 2009 at 06:04:38AM -0400, Stefan Richter wrote:
>> 1.)  It depends on the rootdelay so big that it is guaranteed that one 
>> or more initdev_found() have been called before prepare_namespace()'s 
>> ssleep(root_delay) is over.
...
> I think you misunderstood.  Buses are enumerated before this code is
> reached and thus initdev_found() has already been called for all attached
> block devices.
...
> I would appreciate it if you could take a closer look at the locations where
> initdev_found() and initdev_probe_done() are called and see if you still
> think there is a problem.

I obviously need to do that.

However, one issue remains:  If somebody wants to use your API for 
another bus, he needs to know at which point he can successfully use it, 
and after what point (or context) it cannot, even must not, be used 
anymore.  This isn't documented --- or is it?

(By 'buses are enumerated before...' you surely mean only the buses for 
which you implemented this API usage already.)
-- 
Stefan Richter
-=====-==--= -==- -=--=
http://arcgraph.de/sr/
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
