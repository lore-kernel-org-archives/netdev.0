From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: IP_MULTICAST_IF getsockopt man part
Date: Fri, 4 May 2012 11:00:14 +0200
Message-ID: <20120504090013.GA2362@minipsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi.

<quote>
IP_MULTICAST_IF (since Linux 1.2)
	              Set the local device for a multicast socket.
		      Argument is an ip_mreqn or ip_mreq structure
		      similar to IP_ADD_MEMBERSHIP.
</quote>

That is not true. Setsockopt recognizes only ip_mreqn and in_addr. I
made patch which makes it recognize ip_mreq as well. So that would be
probably ok.
http://patchwork.ozlabs.org/patch/156815/

On the other hand, getsockopt works only with in_addr. That I think is
good behaviour but manpages here needs to be corrected in this way (read
part needs to be added here)

Thanks!

Jirka
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
