From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Questions wrt QoS code on Linux
Date: Thu, 12 May 2005 14:20:01 +0200
Message-ID: <20050512122001.GI28419@postel.suug.ch>
References: <20050512044040.61360.qmail@web31504.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jonathan Day <imipak@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20050512044040.61360.qmail@web31504.mail.mud.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Jonathan Day <20050512044040.61360.qmail@web31504.mail.mud.yahoo.com> 2005-05-11 21:40
> First off, I notice that all the code is lumped
> together and much of it is generically labelled
> "scheduling". I'm wondering if it might not be more
> readable if the list were divided into four sections -
> "queueing disciplines", "scheduling", "packet
> classification" and "everything else". Would that seem
> sensible? Or would it risk making things
> over-structured?

Sounds reasonable although I'm not sure if I understand
the difference between "scheduling" and "qdisc".

> Secondly, there seem to be an awful lot of QoS methods
> not represented in Linux. Implementing them all might
> easily double the kernel size for not very much
> benefit, even if anyone could find the time to do so.
> On the other hand, there are probably some that are
> under development and others high on the wishlist.
> Does anyone know what projects are currently underway
> or being planned?

We're lacking feedback on this subject from the users, we hear
a lot from the typical home user wanting to get some control
over his ADSL/cable link but not much from other areas.

There have been some recent additions, mainly Jamal's actions
and my small ematch API. They perfectly serve as a base to
solve more complex problems but are still in a early stage
of completness and documentation.

The current development direction is to get away from big and
complex problem solvers and focus on tiny and simple components
that can be put together to solve problems more individually.
