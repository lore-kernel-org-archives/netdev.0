From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] (5/6) ibmtr -- probe2
Date: Thu, 16 Oct 2003 13:08:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031016130858.1751ce27.shemminger@osdl.org>
References: <OFF934C8CA.6C5807E0-ON88256DC1.007CA7CB-88256DC1.007DB00E@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mike_Phillips@URSCorp.com
In-Reply-To: <OFF934C8CA.6C5807E0-ON88256DC1.007CA7CB-88256DC1.007DB00E@urscorp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 16 Oct 2003 15:52:50 -0700
Mike_Phillips@URSCorp.com wrote:

> 
> > typedef struct ibmtr_dev_t {
> > +    struct tok_info         ti;         /* must be first! */
> 
> Why must this be first ?? Sounds like an alignment issue, we shouldn't
> assume some is aligned correctly just because it's the first entry.

Because ibmtr_cs calls ibmtr_probe1 function which does:
	struct tok_info *ti = dev->priv;
and dereferences it in a couple of places.
