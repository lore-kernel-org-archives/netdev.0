From: jamal <hadi@cyberus.ca>
Subject: Re: tulip NAPI patch that works with 2.4.20-pre9 or so?
Date: Tue, 22 Oct 2002 20:54:48 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0210222049440.24323-100000@shell.cyberus.ca>
References: <3DB44966.1070402@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3DB44966.1070402@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Mon, 21 Oct 2002, Ben Greear wrote:

> jamal wrote:
> > Theres a 2419 patch that should work for you at:
> > http://www.cyberus.ca/~hadi/tulip-2419-napi-nifd.gz

Links were wrong, prefix is:
http://www.cyberus.ca/~hadi/patches

> Do you have any descriptions of what this feed patch does differently
> from other drivers?

Id rather not tell you since we are still evaluating its usefullness
and it may not be there next week.

Anyways, i put a patched driver - so you only need to pick the extra
patch:
http://www.cyberus.ca/~hadi/patches/tulip-feed-patched.tgz
this + the core patch from Roberts site.

Make sure you edit tulip.h and edit the number of CPUS you have
to avoid NR_CPU stupidity.

cheers,
jamal
