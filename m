From: jamal <hadi@cyberus.ca>
Subject: Re: SMP Re-ordering ?
Date: Fri, 19 Apr 2002 06:58:24 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0204190655010.1274-100000@shell.cyberus.ca>
References: <20020419021031.24839.qmail@web13003.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Yan-Fa Li <yanfali@yahoo.com>
In-Reply-To: <20020419021031.24839.qmail@web13003.mail.yahoo.com>
List-Id: netdev.vger.kernel.org


Yan,

On Thu, 18 Apr 2002, Yan-Fa Li wrote:

> However, a network device I'm testing between my hosts
> keeps seeing re-ordered TCP sessions.  When I reboot and
> specify maxcpus=1 and re-run the test I get none.
>

Strange indeed.

> Am I doing something really wrong here or does this
> workaround no longer work ?
>

IRQ affinity should work and so should NAPI.
How are you proving packets are re-ordered? Could it be the device
driver?

cheers,
jamal
