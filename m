From: bert hubert <ahu@ds9a.nl>
Subject: Re: 2.6.0-test4, 2.5.47, child qdiscs, parent not filled out?
Date: Wed, 3 Sep 2003 23:09:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903210939.GA27592@outpost.ds9a.nl>
References: <20030903102803.GA11876@outpost.ds9a.nl> <Pine.LNX.4.33.0309032258290.521-100000@devix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: devik <devik@cdi.cz>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0309032258290.521-100000@devix>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 03, 2003 at 11:01:45PM +0200, devik wrote:

> There is no other "parent" info in the struct so it can't be returned
> IMHO. You will have to parse all clases from root to leaves.

That probably means having to understand the innards of all qdiscs? Could
that be done from userspace? Is it in the TCA_OPTIONS attribute?

> Maybe we could add parent handle to qdisc but it is question to
> Alexey probably - I'm not sure how complex would it be to keep
> the field in sync ...

True. 

You can look at why I need this on
CVSROOT=:pserver:anon@outpost.ds9a.nl:/var/cvsroot
password 'cvs' without quotes, module 'netlink++'.

Thanks!

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
