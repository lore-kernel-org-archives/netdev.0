From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Mon, 31 Jul 2006 09:06:06 +1000
Message-ID: <1154300766.4236.5.camel@ras.pc.brisbane.lube>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>
	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>
	 <1150292693.5197.1.camel@jzny2>
	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>
	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>
	 <1151000966.5392.34.camel@jzny2>
	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>
	 <1151158431.6716.95.camel@jzny2>
	 <1153188409.13145.5.camel@ras.pc.brisbane.lube>
	 <44BD56A4.9090002@andyfurniss.entadsl.com>
	 <1153270932.4242.60.camel@ras.pc.brisbane.lube>
	 <44BE46A6.8000207@trash.net>
	 <1153371364.4231.61.camel@ras.pc.brisbane.lube>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lists@andyfurniss.entadsl.com, hadi@cyberus.ca,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:15252 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S964776AbWG3XHf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 19:07:35 -0400
To: hadi@cyberus.ca
In-Reply-To: <1153371364.4231.61.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-07-20 at 14:56 +1000, Russell Stuart wrote:
> On Wed, 2006-07-19 at 16:50 +0200, Patrick McHardy wrote:
> > Please excuse my silence, I was travelling and am still catching up
> > with my mails.
> 
> Sorry.  Had I realised you were busy I would of
> waited.
> 
> > > - As it stands, it doesn't help the qdiscs that use 
> > >   RTAB.  So unless he proposes to remove RTAB entirely 
> > >   the ATM patch as it will still have to go in.
> > 
> > Why? The length calculated by my STABs (or something similar)
> > is used by _all_ qdiscs. Not only for transmission time calculation,
> > but also for statistics and estimators.
> 
> Oh.  I didn't see where it is used for the time 
> calculation in your patch.  Did I miss something,
> or is that the unfinished bit?
> 
> This is possibly my stumbling block.  If you don't remove
> RTAB the ATM patch as stands will be needed.  Your patch
> didn't remove RTAB, and you didn't say it was intended to,
> so I presume it wasn't going to.

It has gone quiet again.  In my mind the one unresolved issue
is whether Patrick intended to remove RTAB with his patch.
If not, the ATM patch as it stands will have to go in.

Patrick - it would be nice to hear from you.



