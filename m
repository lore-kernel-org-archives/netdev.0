From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Thu, 4 Mar 2004 22:56:26 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403042229210.1130@u.domain.uli>
References: <20031212003143.062598e9.davem@redhat.com>
 <Pine.LNX.4.44.0312130205460.7978-100000@u.domain.uli>
 <20040304013618.31a827ba.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: niv@us.ibm.com, ak@suse.de, ruddk@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040304013618.31a827ba.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 4 Mar 2004, David S. Miller wrote:

> Julian, I'd like to bring this back to life.  Can you post a new version
> of the ip_rt_ignore_tos patch against current 2.6.x?

	Done. Essentially, this patch combines the last posted
two diff files:

http://www.ssi.bg/~ja/tmp/tos-6.diff

> We'll discuss and integrate just like for the ARP stuff.
>
> Sorry for sitting on this for so long, been busy...

	np, the remaining questions are:

- do we need to walk all tos values for ip_rt_redirect in the same
way as for ip_rt_frag_needed, if yes, how to name this flag?
icmp_redirect_tos_mode? match_tos_on_redirect? May be
pmtu_mode can be renamed to match_tos_on_pmtu?

- from another thread: whether ICMP redirects modify only
routes via gateway when shared_media is ON:

http://marc.theaimsgroup.com/?l=linux-netdev&m=107109827516060&w=2

At the final I'll change some doc files to explain the new flags.

Regards

--
Julian Anastasov <ja@ssi.bg>
