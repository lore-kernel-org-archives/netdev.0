From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC:  Redirect-Device
Date: Thu, 31 Mar 2005 14:35:31 -0800
Message-ID: <20050331143531.30f4eb8f.davem@davemloft.net>
References: <424C6089.1080507@candelatech.com>
	<1112303627.1073.71.camel@jzny.localdomain>
	<424C6B10.6030200@candelatech.com>
	<1112306031.1073.109.camel@jzny.localdomain>
	<424C7813.4000101@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <424C7813.4000101@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Mar 2005 14:22:11 -0800
Ben Greear <greearb@candelatech.com> wrote:

> > [root@jzny root]# tc
> > Usage: tc [ OPTIONS ] OBJECT { COMMAND | help }
> > where  OBJECT := { qdisc | class | filter }
> >        OPTIONS := { -s[tatistics] | -d[etails] | -r[aw] | -b[atch] file
> > }
> 
> My personal opinion is that netlink sockets are a pain in the ass to deal
> with, and there is no way I want to try to programatically parse the tc
> input or output.
> 
> And probably not so easy to manipulate from a kernel module.
> 
> And BNF cannot be more powerful than a c/c++ program with a byte-buffer
> representing the entire ethernet frame.

So you're not even going to give Jamal's suggestion a try?

If we have the infrastructure to do what you want, we should use it,
not add "yet another way" to do something we can do already.

If adding some clean abstraction layer helps out your cause, that's
fine too.  We could even hack tc to output things in a format that
you might find easier to parse.

'tc' is very powerful, and very shamefully under-utilizied.  You're task
seems the perfect match for it's use.
