From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH]  Break 'budget' dependency on netdev_max_backlog.
Date: Tue, 22 Oct 2002 23:58:27 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210222355410.24323-100000@shell.cyberus.ca>
References: <3DB61EFB.4020401@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DB61EFB.4020401@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Tue, 22 Oct 2002, Ben Greear wrote:

> Is there any way to influence how often the poll loop gets run?

the softirq is scheduled like others. You could play with niceness of
ksoftirqd, however note that you may starve user space etc.
You could also increase that backlog queue, but you will be preempted if
that softirq runs for too long.

cheers,
jamal
