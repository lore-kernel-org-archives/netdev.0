From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] meta ematch
Date: 16 Jan 2005 10:37:54 -0500
Message-ID: <1105889874.1090.613.camel@jzny.localdomain>
References: <20050108145457.GZ26856@postel.suug.ch>
	 <1105363582.1041.162.camel@jzny.localdomain>
	 <20050110211747.GA26856@postel.suug.ch>
	 <1105394738.1085.63.camel@jzny.localdomain>
	 <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net>
	 <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net>
	 <20050114151407.GR26856@postel.suug.ch>
	 <1105887519.1097.597.camel@jzny.localdomain>
	 <20050116150914.GU26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050116150914.GU26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-16 at 10:09, Thomas Graf wrote:

> The lvalue will be TCF_META_ID_INDEV and your rvalue will be
> TCF_META_TYPE_VAR with "eth0" as payload(TCF_EM_META_RVALUE).
> TCF_EM_META_LVALUE will be unused in this case.

ok - i get it. So the rvalue is basically just the data that needs to be
compared against. rvalue confused me a little. If you had called it
meta_data i would have got it right away. But now that you explain it,
makes sense. 

I am not sure iam following yet:

So in the case of indev, you would need to 
- get indev ifindex from skb
- get indev name from skb
- compare the two??

Actually it may be a little overkill to have those two as separate
entities with their own headers etc, no? Why not just store it in the
same fashion you transported it from/to user space? 

I will start looking at the code

cheers,
jamal
