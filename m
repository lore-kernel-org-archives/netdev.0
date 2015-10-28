From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v7 10/10] ss: activate json_writer excluded logic
Date: Wed, 28 Oct 2015 09:17:24 +0100
Message-ID: <20151028081724.GN26876@orbit.nwl.cc>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-11-git-send-email-matthias.tafelmeier@gmx.net>
 <20151027132103.GI26876@orbit.nwl.cc>
 <20151028113941.062d74a3@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>,
	netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:54336 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754811AbbJ1IR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2015 04:17:26 -0400
Content-Disposition: inline
In-Reply-To: <20151028113941.062d74a3@samsung9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2015 at 11:39:41AM +0900, Stephen Hemminger wrote:
> On Tue, 27 Oct 2015 14:21:03 +0100
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > On Thu, Sep 10, 2015 at 09:35:08PM +0200, Matthias Tafelmeier wrote:
> > > This small patch extends the lib json_writer module for formerly
> > > deactivated functionality.  
> > 
> > Why was it deactivated in the first place?
> 
> The code came from another project that wasn't using this
> function.

Ah, I didn't get that the functions he uncomments were not added by his
series in the first place. Still:
- This patch should come before 02/10 which makes use of the uncommented
  functions here.
- jsonw_null() and jsonw_null_field() are still unused, no need to
  uncomment them.
