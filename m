From: devik <devik@cdi.cz>
Subject: Re: 2.6.0-test4, 2.5.47, child qdiscs, parent not filled out?
Date: Wed, 3 Sep 2003 23:01:45 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0309032258290.521-100000@devix>
References: <20030903102803.GA11876@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20030903102803.GA11876@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Devik (I hope we can be friends again :-)), others,

yep I think so :-)

> If I create a cbq with several classes, and attach a qdisc to those classes,
> a later netlink dump (RTM_GETQDISCS) returns parent as 0:0 for that qdisc,
> is this right?

structure Qdisc has DEPRECATED field __parent pointing to parent
qdisc (aparently CBQ needs it).
There is no other "parent" info in the struct so it can't be returned
IMHO.
You will have to parse all clases from root to leaves.

Maybe we could add parent handle to qdisc but it is question to
Alexey probably - I'm not sure how complex would it be to keep
the field in sync ...

devik
