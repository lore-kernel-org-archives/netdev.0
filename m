From: "David S. Miller" <davem@redhat.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Wed, 30 Jul 2003 22:02:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730220223.4c25fcfe.davem@redhat.com>
References: <20030724000705.4662df54.davem@redhat.com>
	<Pine.LNX.4.44.0307291659190.7490-100000@DYN318430>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0307291659190.7490-100000@DYN318430>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Jul 2003 17:33:03 -0700 (PDT)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> Since use_tempaddr can be -1, I am for the time being keeping all
> the variables as s32. If this is changed to __u32, then some code in
> addrconf.c needs to be modified.

Ok, but then please use "__s32".

> > I think something more like route metrics, ie. an array is more appropriate
> 
> I guess you mean only the user interface to use route type metrics, not
> modify the existing cnf implementation to use this concept (eg remove the
> structure and define cnf_metrics[] with code similar to RTAX_HOPLIMIT,
> etc). So this patch doesn't change the usage in kernel, except now the
> user interface returns the config params in an array format.
> 
> This patch applies on top of the prefix list patch.

I like the array scheme, but please you must define macros
(like RTAX_*) that give meaning to the array[] indices.
