From: jamal <hadi@cyberus.ca>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: 30 Aug 2004 18:56:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093906592.1037.32.camel@jzny.localdomain>
References: <1093799632.1073.410.camel@jzny.localdomain>
	 <20040830144033.2265a6e6.davem@redhat.com>
	 <1093904088.1043.12.camel@jzny.localdomain>
	 <20040830154430.769d1d59.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040830154430.769d1d59.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-08-30 at 18:44, David S. Miller wrote:
> On 30 Aug 2004 18:14:48 -0400
> jamal <hadi@cyberus.ca> wrote:

> Check the size, if it matches the older tc_stats size sans
> requeue stat addition, then don't try to reference that struct member.
> 
> 	if (RTA_PAYLOAD(tb[TCA_STATS]) == sizeof(struct tc_stats_old)) {
> 		/* report everything sans requeue */
> 	} else if (RTA_PAYLOAD(tb[TCA_STATS]) == sizeof(struct tc_stats)) {
> 		/* report all stats, including requeue */
> 	} else {
> 		/* report error, etc. */
> 	}

Sounds reasonable to me. Some of the BSDs do this to maintain old compat
- just means keeping old struct around. Steve, agreeable to you? 

Change to both kernel and user space or just user space?

cheers,
jamal
