From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] nfmark modify extension to classifiers
Date: Tue, 7 Oct 2003 03:28:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007012858.GF11250@rei.reeler.org>
References: <20031006002619.GC11250@rei.reeler.org> <1065479986.1102.3.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, Alexey <kuznet@ms2.inr.ac.ru>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1065479986.1102.3.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello

> This is a bad idea.
> Please consider using the tc action extensions. 

You mean TC_POLICE_NFMARK? This was actually my initial idea
but I wanted to avoid a dependency mess.

> I was going to write a generic metadata modifier action
> (classid, tcindex, nfmark etc). Maybe you can beat me to it.

I also thought about that, more specificly: Extend tcf_result
and set nfmark/tcindex in tc_classify?

There are so many solutions to this and I have no clue what
is the best solution.

Regards

-- 
Thomas GRAF <tgraf@suug.ch>
