From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: TODO list before feature freeze
Date: Fri, 19 Jul 2002 09:39:36 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020719073936.GE7933@balabit.hu>
References: <20020718093928.18BC942CD@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
   netfilter-core@lists.netfilter.org
Return-path: <owner-netdev@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Content-Disposition: inline
In-Reply-To: <20020718093928.18BC942CD@lists.samba.org>
List-Id: netdev.vger.kernel.org

On Thu, Jul 18, 2002 at 07:34:53PM +1000, Rusty Russell wrote:
> Hi all,
> 
> 	With four months to go before the feature freeze, it's
> important to compile a feature list for netfilter-related things.  I
> see the following coming up:
> 
> Connection tracking:
> 	o TCP window tracking finally goes in.
> 	o Fix the extremely low TCP RST timeout
> 	o Fix the UDP timeout calculations to be per-port.
> 	o Improve hashing
> 	o Fix the massive timer performance problem.
> 	o Zero-copy-safe the connection tracking framework
> 	o ctnetlink support
> 
> iptables:
> 	o Change over to a netlink interface
> 		o Back to add/delete/replace interface + commit.
> 	o Rewrite libiptc to use netlink (to port iptables).
> 	o Write new ip extension for iptables.
> 	o Zero-copy-safe the iptables framework
> 
> NAT:
> 	o Zero-copy-safe the NAT framework
> 
> Please add feature requests: note that I have not been following the
> lists, so "obvious" things may not be obvious to me.

I think conntrack exemptions and transparent proxy support should be added
to the list. The latter is working for me in production at least for TCP
connections. UDP support is to be dependant on conntrack exemptions, so that
is not yet implemented. (at least the sendmsg side, the recvmsg side should
be working)

-- 
Bazsi
PGP info: KeyID 9AF8D0A9 Fingerprint CD27 CFB0 802C 0944 9CFD 804E C82C 8EB1
