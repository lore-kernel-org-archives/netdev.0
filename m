From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2.6] (1/4) netem - update API for new features
Date: 26 Aug 2004 14:13:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093544037.1027.130.camel@jzny.localdomain>
References: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
	 <1093522131.1043.84.camel@jzny.localdomain>
	 <20040826091649.26d6cd72@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040826091649.26d6cd72@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-08-26 at 12:16, Stephen Hemminger wrote:
> On 26 Aug 2004 08:08:51 -0400
> jamal <hadi@cyberus.ca> wrote:
[..]
> > 
> > You should really send the delay_dist in its own TLV to avoid
> > the kind of mistakes that showed up in u32 classifier.
> > Also allows you to extend that structure in the future.
> > 
> > cheers,
> > jamal
> 
> It would be good but the whole qdisc api (init, change) is really structured
> around a single TLV.

Just pass nested attributes. The API is fine.

cheers,
jamal
