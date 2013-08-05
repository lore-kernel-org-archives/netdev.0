From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] hostap: do not return positive number on failure path
 in prism2_open()
Date: Sun, 04 Aug 2013 20:33:36 -0700
Message-ID: <1375673616.3133.23.camel@joe-AO722>
References: <1375672708-3017-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <j@w1.fi>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org
To: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375672708-3017-1-git-send-email-khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-08-05 at 07:18 +0400, Alexey Khoroshilov wrote:
> prism2_open() as an .ndo_open handler should not return positive numbers
> in case of failure, but it does return 1 in a couple of places.
> 
> Found by Linux Driver Verification project (linuxtesting.org).

How?

http://linuxtesting.org/project/ldv
http://linuxtesting.org/results/ldv

Shows defects and patches to fix them, but not any script
used to find it.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
