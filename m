From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: Function to read IP address in dot format
Date: Mon, 11 Apr 2005 07:07:23 -0700
Message-ID: <20050411070723.5de5e286.rddunlap@osdl.org>
References: <20050411060510.12208.qmail@web52201.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux lover <linux_lover2004@yahoo.com>
In-Reply-To: <20050411060510.12208.qmail@web52201.mail.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 10 Apr 2005 23:05:10 -0700 (PDT) linux lover wrote:

| 
| Hello,
|           what is the function to read IP address in
| kernel code as human readable dot quad format? IP
| address are unsigned int's in ip.h file as
|         __u32   saddr;
|         __u32   daddr;
|          In ip_build_xmit ip header gets IP addresses
| from rtable struct as
| iph->saddr=rt->rt_src;
| iph->daddr=rt->rt_dst;
|            Now if i want to know to which ip current
| packet is being sent i am using printks but it prints
| iph->saddr in int format not in user readable format.
| how to do that?

Look at the NIPQUAD() macro in include/linux/kernel.h
and at some example uses of it.

---
~Randy
