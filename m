From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] nfmark modify extension to classifiers
Date: 12 Oct 2003 16:00:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1065988858.5373.11.camel@jzny.localdomain>
References: <20031006002619.GC11250@rei.reeler.org>
	 <1065479986.1102.3.camel@jzny.localdomain>
	 <20031007012858.GF11250@rei.reeler.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, Alexey <kuznet@ms2.inr.ac.ru>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20031007012858.GF11250@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-10-06 at 21:28, Thomas Graf wrote:
> Hello
> 
> > This is a bad idea.
> > Please consider using the tc action extensions. 
> 
> You mean TC_POLICE_NFMARK? This was actually my initial idea
> but I wanted to avoid a dependency mess.
> 

I meant this:
http://www.cyberus.ca/~hadi/patches/action/README

so you can do:
tc filter add dev lo parent ffff: protocol ip prio 10 u32 match ip src \
127.0.0.1/32 flowid 1:1 ....
action metaset classid 1:14 nfmark 0x10 ...


cheers,
jamal
