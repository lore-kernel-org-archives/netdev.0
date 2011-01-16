From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] 9p: fix min_t() casting
Date: Sun, 16 Jan 2011 14:45:26 +0300
Message-ID: <20110116114526.GG2721@bicker>
References: <20110115203539.GF2721@bicker>
 <20110115.205208.104051310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ericvh@gmail.com, sripathik@in.ibm.com, jvrao@linux.vnet.ibm.com,
	aneesh.kumar@linux.vnet.ibm.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, mohan@in.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43468 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab1APLpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jan 2011 06:45:45 -0500
Content-Disposition: inline
In-Reply-To: <20110115.205208.104051310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 15, 2011 at 08:52:08PM -0800, David Miller wrote:
> From: Dan Carpenter <error27@gmail.com>
> Date: Sat, 15 Jan 2011 23:35:39 +0300
> 
> > The intent here was to cap the length to USHRT_MAX, but what the
> > code actually does is it just casts the return from strlen() to
> > unsigned short and truncates the significant bits away.
> > 
> > Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> If you want me to apply this, it doesn't apply cleanly to net-2.6
> at all.

Sorry.  I screwed up.

This was on top of a patch from M. Mohan Kumar <mohan@in.ibm.com>
that hasn't hit net-2.6 yet.  Mohan wasn't included on the CC
list because get_maintainer.pl changed and I didn't notice and 
I wasn't careful.

Eric, could Mohan just fix his patch before it gets merged or is it
better to send these as two patches?

regards,
dan carpenter

Ps:  Mohon the patch is here:
http://marc.info/?l=linux-netdev&m=129512381528034&w=2
