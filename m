From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: Mon, 30 Aug 2004 19:17:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830191716.0d002f91.davem@redhat.com>
References: <1093799632.1073.410.camel@jzny.localdomain>
	<20040830144033.2265a6e6.davem@redhat.com>
	<1093904088.1043.12.camel@jzny.localdomain>
	<20040830154430.769d1d59.davem@redhat.com>
	<1093906592.1037.32.camel@jzny.localdomain>
	<20040830160052.548c4846.davem@redhat.com>
	<1093916592.1037.51.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093916592.1037.51.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 30 Aug 2004 21:43:13 -0400
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2004-08-30 at 19:05, Stephen Hemminger wrote: 
> 
> > I have no problem but easier to just do something:
> > 	struct tc_stats mystats;
> > 
> > 	memset(&mystats, 0, sizeof(mystats));
> > 	memcpy(&mystats, RTA_DATA(tb[TCA_STATS]), RTA_PAYLOAD(tb[TCA_STATS]));
> > 
> > that way it can grow as much as we want and don't have v1, v2, v3, ... 
> > size structures.
> 
> Not sure i parsed that. You mean the tc_stats in user space will be the new 
> one.

Yes, that's his idea.  This way on older kernel the "new" statistics
just show up as zero.
