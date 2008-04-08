From: Stephen Hemminger <stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [ANN] WiMAX stack and drivers for Intel WiMAX Link 5050
Date: Tue, 8 Apr 2008 14:04:03 -0500
Message-ID: <20080408140403.3e7191bb@speedy>
References: <200804011107.38563.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wimax-BPSAo7wm5JOHVYUYWc+uSQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Inaky Perez-Gonzalez <inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200804011107.38563.inaky-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Looking at the kernel/user interface: wimax-tools-1.1/lib/op-open.c

This API is repeating the mistake of the old Linux Wireless API. It is putting version
checks between kernel and library and this is a maintenance nightmare. Linux
API's are not COM. Versioning is a mistake.  Use a TLA api like netlink so it
can be extensible without version handshake.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
