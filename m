From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: re: NFC: Initial LLCP support
Date: Fri, 16 Dec 2011 23:26:59 +0300
Message-ID: <20111216202659.GD18570@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Samuel Ortiz,

This is a semi-automatic email about new static checker warnings.

The patch d646960f7986: "NFC: Initial LLCP support" from Dec 14, 
2011, leads to the following Smatch complaint:

net/nfc/llcp/sock.c +47 llcp_sock_bind()
	 warn: variable dereferenced before check 'addr' (see line 45)

net/nfc/llcp/sock.c
    44	
    45		pr_debug("sk %p addr %p family %d\n", sk, addr, addr->sa_family);
                                                                ^^^^^^^^^^^^^^^
New dereference.

    46	
    47		if (!addr || addr->sa_family != AF_NFC)
                     ^^^^
New check.

    48			return -EINVAL;
    49	

regards,
dan carpenter

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
