From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] iproute2 skbedit: Add support to mark packets
Date: Thu, 4 Mar 2010 09:43:23 -0800
Message-ID: <20100304094323.05fce73a@nehalam>
References: <1259847168.3766.40.camel@bigi>
	<20100303163638.09520577@nehalam>
	<1267671091.4821.27.camel@bigi>
	<20100304084829.22a80ace@nehalam>
	<1267721912.4821.37.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50799 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752047Ab0CDRn3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Mar 2010 12:43:29 -0500
In-Reply-To: <1267721912.4821.37.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 Mar 2010 11:58:32 -0500
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2010-03-04 at 08:48 -0800, Stephen Hemminger wrote:
> > On Wed, 03 Mar 2010 21:51:31 -0500
> > jamal <hadi@cyberus.ca> wrote:
> > 
> > > You applied 2/2 but not 1/2.
> 
> > > > 
> > 
> > The first was the help message text, and that was already there.
> > Or was there some other bit.
> 
> I can see that now. The git logs dont show how that change
> made it in - thats how i concluded it wasnt there. How did that 
> sneak in there?

I put the first bit in back in December. It was too early since
kernel wasn't ready yet, but generally harmless


commit e04dd30a38130a3d85065a747cc33274766a9cb6
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Sat Dec 26 11:12:43 2009 -0800

    skbedit: Add support to mark packets
    
    This adds support for setting the skb mark.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
    Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
