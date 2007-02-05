From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 2/2] d80211: Add software sequence support
Date: Mon, 5 Feb 2007 18:56:20 +0100
Message-ID: <200702051856.20919.IvDoorn@gmail.com>
References: <200701312016.52221.IvDoorn@gmail.com> <200702031245.27035.IvDoorn@gmail.com> <20070205183714.3d89ec61@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.243]:22197 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbXBER4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 12:56:48 -0500
Received: by an-out-0708.google.com with SMTP id b33so1085192ana
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 09:56:47 -0800 (PST)
In-Reply-To: <20070205183714.3d89ec61@griffin.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 05 February 2007 18:37, Jiri Benc wrote:
> On Sat, 3 Feb 2007 12:45:26 +0100, Ivo van Doorn wrote:
> > --- dscape/net/d80211/ieee80211_i.h	2007-01-31 19:41:53.000000000 +0100
> > +++ dscape_seq/net/d80211/ieee80211_i.h	2007-01-31 20:06:26.000000000 +0100
> > @@ -405,6 +405,7 @@
> >  	int *supp_rates[NUM_IEEE80211_MODES];
> >  	int *basic_rates[NUM_IEEE80211_MODES];
> >  
> > +	u16 seq_counter;
> 
> Shouldn't this be per-BSS?

Ok I'll try to get a per-BSS sequence counter working,
I'll need some time to figure out how the per-BSS code is working.

Ivo
