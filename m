From: Jan Dittmer <jdi@l4x.org>
Subject: Re: [PATCH 01/02 V3] net/ipv6: seperate sit driver to extra module
Date: Fri, 13 Oct 2006 20:12:06 +0200
Message-ID: <452FD6F6.3090907@l4x.org>
References: <20061010153745.GA27455@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751785AbWJMSMk@vger.kernel.org>
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20061010153745.GA27455@zlug.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is missing the MODULE_LICENSE statements and taints the kernel upon
loading. License is obvious from the beginning of the file.

Joerg Roedel wrote:
> --- linux-2.6.18-vanilla/net/ipv6/sit.c	2006-09-20 05:42:06.000000000 +0200
> +++ linux-2.6.18/net/ipv6/sit.c	2006-10-05 16:55:02.000000000 +0200
> @@ -850,3 +850,6 @@ int __init sit_init(void)
>  	inet_del_protocol(&sit_protocol, IPPROTO_IPV6);
>  	goto out;
>  }
> +
> +module_init(sit_init);
> +module_exit(sit_cleanup);

Signed-off-by: Jan Dittmer <jdi@l4x.org>

--- linux-2.6-amd64/net/ipv6/sit.c~	2006-10-13 17:39:45.000000000 +0200
+++ linux-2.6-amd64/net/ipv6/sit.c	2006-10-13 17:39:49.000000000 +0200
@@ -853,3 +853,4 @@ int __init sit_init(void)

 module_init(sit_init);
 module_exit(sit_cleanup);
+MODULE_LICENSE("GPL");
