From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] meta ematch
Date: 16 Jan 2005 11:19:21 -0500
Message-ID: <1105892360.1091.655.camel@jzny.localdomain>
References: <20050110211747.GA26856@postel.suug.ch>
	 <1105394738.1085.63.camel@jzny.localdomain>
	 <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net>
	 <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net>
	 <20050114151407.GR26856@postel.suug.ch>
	 <1105887519.1097.597.camel@jzny.localdomain>
	 <20050116150914.GU26856@postel.suug.ch>
	 <1105889874.1090.613.camel@jzny.localdomain>
	 <20050116155758.GV26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050116155758.GV26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-16 at 10:57, Thomas Graf wrote:

> The rvalue may also point to a metadata in the kernel. This gets
> useful when comparing dev against real dev or if nfmark, tcindex,
> you name it carries a ifindex for example. It would even be possible
> to compare two strings from userspace but that wouldn't make sense.
> The only difference between lvalue and rvalue is that the lvalue
> carries the operand.
> 

ok, more clarity.

> 
> > I am not sure iam following yet:
> > 
> > So in the case of indev, you would need to 
> > - get indev ifindex from skb
> > - get indev name from skb
> > - compare the two??
> >

Can you explain the above in context of indev = "eth0"? I am still not
sure i get it:

+     if (meta_get(skb, info, &meta->lvalue, &l_value) < 0 ||
+         meta_get(skb, info, &meta->rvalue, &r_value) < 0)
+             return 0;
+     r = meta_type_ops(&meta->lvalue)->compare(&l_value, &r_value);


cheers,
jamal
