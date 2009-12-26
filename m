From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/3] iproute: fix tc ipt/xt module.
Date: Sat, 26 Dec 2009 11:18:30 -0800
Message-ID: <20091226111830.593eb002@nehalam>
References: <cover.1259765732.git.andreas@fatal.se>
	<1259845778.3766.32.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andreas Henriksson <andreas@fatal.se>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58515 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753529AbZLZTSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Dec 2009 14:18:47 -0500
In-Reply-To: <1259845778.3766.32.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Dec 2009 08:09:38 -0500
jamal <hadi@cyberus.ca> wrote:

> 
> On Wed, 2009-12-02 at 16:10 +0100, Andreas Henriksson wrote:
> > The xtables API has changed since the tc xt module was written.
> > This mini-series moves the legacy stuff out of the way (kept for
> > compatibility with older iptables versions) and starts
> > a new fresh xt module.
> > 
> > Hopefully the xtables api will be kept stable in the future.
> > If so, this new xt module should continue working since it only
> > uses exposed functions (unlike the old one which had an internal
> > header to access internal functions in xtables).
> > 
> > Andreas Henriksson (3):
> >   Keep the old tc/ipt/xt module for compatibility.
> >   Add new (iptables 1.4.5 compatible) tc/ipt/xt module.
> >   Slightly improve the configure script.
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> Andreas, in the future can you CC me please - I dont read netdev
> in real time (sometimes i catch up in a month and skim over).
> 
> cheers,
> jamal
> 

These all went int to the 2.6.32 version of iproute2

-- 
