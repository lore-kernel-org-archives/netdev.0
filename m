From: Patrick Schaaf <bof@bof.de>
Subject: Re: TODO list before feature freeze
Date: Mon, 29 Jul 2002 18:45:20 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020729184520.F570@oknodo.bof.de>
References: <20020729131239.A5183@wotan.suse.de> <Pine.GSO.4.30.0207290719580.12604-100000@shell.cyberus.ca> <20020729182659.D570@oknodo.bof.de> <20020729183116.B27940@wotan.suse.de> <20020729184239.E570@oknodo.bof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, jamal <hadi@cyberus.ca>,
   Rusty Russell <rusty@rustcorp.com.au>, netfilter-devel@lists.netfilter.org,
   netdev@oss.sgi.com, netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: Patrick Schaaf <bof@bof.de>
Content-Disposition: inline
In-Reply-To: <20020729184239.E570@oknodo.bof.de>; from bof@bof.de on Mon, Jul 29, 2002 at 06:42:39PM +0200
List-Id: netdev.vger.kernel.org

> This week (probably wednesday) I'll put both my netfilter hook statistic
> patch, and enabled kernel profiling, onto a production box (the transproxy
> thing from the bucket occupation analysis). Right now I have totally
> undersized bucket count on that machine (7168 buckets for 10 times
> the tuples), so I'll first measure the "accidental long list walk"
> situation, and then retry with a suitable bucket size.

Before somebody get the wrong idea: the machine I mentioned, serves
as a squid proxy for over 3000 narrowband dialup users (all web
traffic), and it has no performance problems at all with that.
For all I know, any optimization we may make regarding netfilter,
won't make the squids on that box work perceivably better.

I have permanent average and median service time monitoring to prove
or disprove this assertion :-)

best regards
  Patrick
