From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool 3/3] ethtool: add ETHTOOL_{G,S}CHANNEL support.
Date: Tue, 04 Oct 2011 23:36:39 +0100
Message-ID: <1317767799.2751.33.camel@bwh-desktop>
References: <1316514695-17157-1-git-send-email-sucheta.chakraborty@qlogic.com>
	 <1316514695-17157-4-git-send-email-sucheta.chakraborty@qlogic.com>
	 <1317766902.2751.25.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7297 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933511Ab1JDWgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 18:36:44 -0400
In-Reply-To: <1317766902.2751.25.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-10-04 at 23:21 +0100, Ben Hutchings wrote:
> On Tue, 2011-09-20 at 03:31 -0700, Sucheta Chakraborty wrote:
> > Used to configure number of rx and tx rings.
> > Reqd. man page changes are included.
> [...]
> > @@ -754,6 +764,24 @@ lB	l.
> >  Specify the location/ID to insert the rule. This will overwrite
> >  any rule present in that location and will not go through any
> >  of the rule ordering process.
> > +.TP
> > +.B \-l \-\-show\-channels
> > +Queries the specified network device for channel parameter information.
> > +.TP
> > +.B \-L \-\-set\-channels
> > +Changes the channel parameters of the specified network device.
> 
> I think the manual page needs to explain briefly what is meant by a
> channel.  (So should ethtool.h, really!)
[...]

Perhaps something like this:

.TP
.B \-l \-\-show\-channels
Queries the specified network device for the numbers of channels it has.
A channel is an IRQ and the set of queues that can trigger that IRQ.
.TP
.B \-L \-\-set\-channels
Changes the numbers of channels of the specified network device.
.TP
.BI rx \ N
Changes the number of channels with only receive queues.
.TP
.BI tx \ N
Changes the number of channels with only transmit queues.
.TP
.BI other \ N
Changes the number of channels used only for other purposes e.g. link
interrupts or SR-IOV co-ordination.
.TP
.BI combined \ N
Changes the number of multi-purpose channels.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
