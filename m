From: James Morris <jmorris@intercode.com.au>
Subject: Re: How kernel send message to daemon?
Date: Sat, 7 Dec 2002 00:27:16 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0212070026400.13427-100000@blackbird.intercode.com.au>
References: <004701c29d09$a58e7b40$6c06a8c0@zhengjp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Zheng Jianping <zjp@iscas.ac.cn>
In-Reply-To: <004701c29d09$a58e7b40$6c06a8c0@zhengjp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Dec 2002, Zheng Jianping wrote:

> Hi,
> 
> In IPv6 packet forwarding processing, the kernel receives a 'bad'
> message. Now I want the kernel inform the daemon( a routing protocl ) .
> Howto?

Try Netlink (have a look at rtnetlink.c).

-- 
James Morris
<jmorris@intercode.com.au>
