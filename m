From: Alexandre Cassen <acassen@freebox.fr>
Subject: Re: [PATCH][RESEND] IPv6: 6rd tunnel mode
Date: Tue, 22 Sep 2009 08:59:32 +0200
Message-ID: <1253602772.17175.13.camel@lnxos-dev>
References: <20090922003956.GA19947@lnxos.staff.proxad.net>
	 <4AB838F1.1090704@hp.com>
Reply-To: acassen@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:38119 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755262AbZIVHAJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2009 03:00:09 -0400
In-Reply-To: <4AB838F1.1090704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brian,

On Mon, 2009-09-21 at 22:39 -0400, Brian Haley wrote:
> Hi Alexandre,
> 
> Alexandre Cassen wrote:
> > This patch add support to 6rd tunnel mode currently targetting
> > standard track at the IETF.
> > 
> > IPv6 rapid deployment (RFC5569) builds upon mechanisms of 6to4 (RFC3056)
> > to enable a service provider to rapidly deploy IPv6 unicast service
> > to IPv4 sites to which it provides customer premise equipment.  Like
> > 6to4, it utilizes stateless IPv6 in IPv4 encapsulation in order to
> > transit IPv4-only network infrastructure. Unlike 6to4, a 6rd service
> > provider uses an IPv6 prefix of its own in place of the fixed 6to4
> > prefix.
> 
> I couldn't find RFC 5569 (delayed due to IPR rights?), although I did find
> the latest 6rd draft, -03.  It was showing as Informational, not Standards
> track, is that right?  Just curious.

In fact there is currently two draft :

1) https://datatracker.ietf.org/idtracker/draft-despres-6rd/

   This draft is targeting informational RFC as an independent
submission. It is currently queued and has been delayed since may for
IPR.

2) http://tools.ietf.org/html/draft-townsley-ipv6-6rd-01

   This draft is targeting standard track so work is in progress here.

A good sum up has been done by Mark Townsley at last IETF meeting :

http://www.ietf.org/proceedings/75/slides/dhc-4.pdf

> > +		case SIOCADD6RD:
> > +		case SIOCCHG6RD:
> > +			if (ip6rd.prefixlen >= 95) {
> > +				err = -EINVAL;
> > +				goto done;
> > +			}
> > +			t->ip6rd_prefix.addr = ip6rd.addr;
> 
> ipv6_addr_copy(&t->ip6rd_prefix.addr, &ip6rd.addr); is the preferred way to
> copy the address.

agreed. will fix and resend.

regs,
Alexandre

