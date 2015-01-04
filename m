From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 v2 2/3] ss: Unify packet stats output from
 netlink and proc
Date: Sun, 4 Jan 2015 20:32:18 +0200
Message-ID: <20150104183218.GA13666@angus-think.lan>
References: <1420392055-4754-1-git-send-email-vadim4j@gmail.com>
 <1420392055-4754-3-git-send-email-vadim4j@gmail.com>
 <20150104103008.1648dcb8@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:64106 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752662AbbADSmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 13:42:38 -0500
Received: by mail-lb0-f172.google.com with SMTP id z12so9016231lbi.3
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 10:42:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150104103008.1648dcb8@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 04, 2015 at 10:30:08AM -0800, Stephen Hemminger wrote:
> On Sun,  4 Jan 2015 19:20:54 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > +struct pktstat {
> > +	int type;
> > +	int prot;
> > +	int iface;
> > +	int state;
> > +	int rq;
> > +	int uid;
> > +	int ino;
> > +};
> 
> Rather than copying the original data types, this structure should use the
> correct types that already exist. 
> For example: type is pdiag_type which is __u8 therefore it should be __u8 or uint8_t.
> 
> Likewise uid should be uid_t etc.

Thats good point, but it would be good to do this for all xxxstats
struct's, may be in separated patch ?

Regards,
