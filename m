From: Ralph Doncaster <ralph@istop.com>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Wed, 13 Aug 2003 17:10:56 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0308131707280.21992@ns.istop.com>
References: <3F16A0E5.1080007@hipac.org> <1059934468.1103.41.camel@jzny.localdomain>
 <3F2E5CD6.4030500@hipac.org> <1060012260.1103.380.camel@jzny.localdomain>
 <3F302E04.1090503@hipac.org> <1060286331.1025.73.camel@jzny.localdomain>
 <3F381B3E.6080807@hipac.org> <20030811224050.59bc36fe.davem@redhat.com>
 <20030812142913.GB18802@mail.jlokier.co.uk> <Pine.LNX.4.51.0308131320470.13253@ns.istop.com>
 <20030813191757.GE4405@mail.jlokier.co.uk>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamie Lokier <jamie@shareable.org>
In-Reply-To: <20030813191757.GE4405@mail.jlokier.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 13 Aug 2003, Jamie Lokier wrote:

> You would start by search for a 217.109.0.0/16 entry.  That's
> the root in the search tree.
>
> That would match, and the matching tree node would tell you to search
> a specific table for 217.109.118.0/24.  (Actually, just
> 0.0.118.0/0.0.255.0, because this node can assume the first 16 bits).

So you have to put an entry in the /16 table for every /16 that you have a
more specific route for, right?
Then what if I have 3 different routes; one for 217.109.0.0/16, another
for 217.109.118.0/24 and one for 217.109.118.68/32?

-Ralph
