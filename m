From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPv6 IPComp
Date: Sat, 17 May 2003 10:08:55 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0305171006330.18517-100000@excalibur.intercode.com.au>
References: <20030516.165232.23034665.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030516.165232.23034665.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 16 May 2003, David S. Miller wrote:

>    Date: Sat, 17 May 2003 07:27:45 +0900 (JST)
> 
>    In article <Pine.LNX.4.44.0305170035010.22475-100000@netcore.fi> (at Sat, 17 May 2003 00:35:43 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:
>    
>    > > + * IP Payload Compression Protocol (IPComp) for IPv6 - RFC3713
>    > 
>    > What?!? Such RFC does not exist :-)
>    
>    Oops... :-p
>    
> Fix applied, thanks :-)
> 

IPv4 was using an RFC from the future as well.


- James
-- 
James Morris
<jmorris@intercode.com.au>

--- bk.pending/net/ipv4/ipcomp.c	Thu May 15 15:55:41 2003
+++ bk.w1/net/ipv4/ipcomp.c	Sat May 17 10:53:09 2003
@@ -1,5 +1,5 @@
 /*
- * IP Payload Compression Protocol (IPComp) - RFC3713.
+ * IP Payload Compression Protocol (IPComp) - RFC3173.
  *
  * Copyright (c) 2003 James Morris <jmorris@intercode.com.au>
  *
@@ -433,6 +433,6 @@
 module_exit(ipcomp4_fini);
 
 MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("IP Payload Compression Protocol (IPComp) - RFC3713");
+MODULE_DESCRIPTION("IP Payload Compression Protocol (IPComp) - RFC3173");
 MODULE_AUTHOR("James Morris <jmorris@intercode.com.au>");
 
