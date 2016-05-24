From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH iproute2 v3 5/5] ip: add MACsec support
Date: Tue, 24 May 2016 15:12:35 +0200
Message-ID: <20160524131235.GB23050@bistromath.localdomain>
References: <cover.1463585050.git.sd@queasysnail.net>
 <3e4dce017d424cfbd7558a82ddcaf6edf1d03312.1463585050.git.sd@queasysnail.net>
 <20160523162142.0da12bfa@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841AbcEXNMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2016 09:12:38 -0400
Content-Disposition: inline
In-Reply-To: <20160523162142.0da12bfa@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,

2016-05-23, 16:21:42 -0700, Stephen Hemminger wrote:
> On Wed, 18 May 2016 17:35:13 +0200
> Sabrina Dubroca <sd@queasysnail.net> wrote:
> 
> > +
> > +static void print_rx_sc(const char *prefix, __u64 sci, __u8 active, struct rtattr *rxsc_stats, struct rtattr *sa)
> > +{
> 
> Overall, this looks fine, but could you break some of the really long lines.
> In general, I like iproute2 to follow kernel style, and in general stick to
> the 80 column recommendation where it makes sense.  Spliting strings or 
> stuff in loops may not make sense. There are several places in this code
> longer than 100 chars.

Ugh, yeah, I forgot to clean this up, sorry.
I'll do that and resend.


Thanks,

-- 
Sabrina
