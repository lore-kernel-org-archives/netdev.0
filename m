From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: netlink tester program
Date: Sun, 8 Jun 2003 21:35:09 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030608212033.Y33230@shell.cyberus.ca>
References: <20030603075742.34434.qmail@web14305.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: david-b@pacbell.net, rddunlap@osdl.org, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hisham Kotry <etsh_cucu@yahoo.com>
In-Reply-To: <20030603075742.34434.qmail@web14305.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 3 Jun 2003, Hisham Kotry wrote:

> It was defenitly a nice read, but the netlink2 draft
> is somewhat inconsistent, it mentions reducing the
> 32-bit length field to 16-bits and equally
> distributing the remaining 16-bits between the new
> version and extended flags fields, but the draft makes
> no further refrence to the version field. Infact the
> netlink2 message header diagram on page 16, as well as
> the pseudo message on page 28, show a 16-bits extended
> flags field with no version field in the header. So
> this is probably one of those cases in wich specs
> aren't clear enough and code usually has the final
> word in such situations.
>
> I mailed Jamal about this a while ago but never got a
> reply back.
>

apologies, I actually have a unrelated daytime job that tends to keep me
too occupied at times ;->

Netlink2 draft is work in progress. The draft tends to lag reality.
I believe what you refer to has been fixed. Refer to the slides at:
http://www.zurich.ibm.com/~rha/netlink2.pdf

> BTW, is netlink2 support planned for linux in the near
> future?
>

You will see code from us that is GPL. Consider netlink2 as a distributed
netlink. netlink is already proven so why reinvent the wheel?
Essentially you should be able to manager clusters of linux network
devices (think firewalls, routers etc) with netlink/netlink2.
There are some mechanisms for distributdness that are missing. These are
the holes we are going to fill.

Note some of the stuff i am working on at:
www.cyberus.ca/~hadi/patches/action which fits the whole forces paradigm
and works quiet well with netlink today and netlink2 next.
(I stopped updating that web page for sometime now, talk to me if
interested in the patches and if you would like to help in testing,
coding, etc)

cheers,
jamal
