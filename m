From: Patrick Schaaf <bof@bof.de>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 18:26:59 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020729182659.D570@oknodo.bof.de>
References: <20020729131239.A5183@wotan.suse.de> <Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Rusty Russell <rusty@rustcorp.com.au>,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca>; from hadi@cyberus.ca on Mon, Jul 29, 2002 at 07:23:49AM -0400
List-Id: netdev.vger.kernel.org

Jamal,

> They also have a lot of problems with their per-packet computations.
> Robert and I spent a short time looking at "this thing that is making
> us look bad" (perfomance wise) and talked to Harald.

Do you have written up somewhere what kind of performance problems you were
seeing, under which conditions (hash bucket count, number of tracked
connections, packet load)

> Something that looked like needs improvement at first glance was the aging
> and hashing schemes.

Regarding the hashing schemes, please see discussions on netfilter-devel
over the last weeks:

http://lists.netfilter.org/pipermail/netfilter-devel/2002-July/thread.html

and a small presentation of various bucket sizes / hash functions
for some real world scenarios: http://bei.bof.de/ex6/
This presentation, a bit terse on comments, links to a tarball
which allows you to recreate the same presentation for any
dump of /proc/net/ip_conntrack, varying bucket counts and
hash functions.

best regards
  Patrick
