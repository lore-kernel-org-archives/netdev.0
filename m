From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: TUN/TAP: tap driver reports bogus interface speed in ethtool
 operations
Date: Tue, 30 Jul 2013 12:51:17 +0200
Message-ID: <1375181477.13657.0.camel@deadeye.wl.decadent.org.uk>
References: <2F174B03-5074-4BA0-B91A-8F2F62C2B082@cygnusnetworks.de>
	 <5192BDD6.6060703@qti.qualcomm.com>
	 <3E916AF0-C587-443D-B653-C968A96C8751@cygnusnetworks.de>
	 <48A2F278-A32C-47C6-AD2D-1FC15EC73B88@cygnusnetworks.de>
	 <51E5BE27.3060207@qti.qualcomm.com>
	 <E4A37B97-95FE-42C3-AD78-119BA406A44A@cygnusnetworks.de>
	 <1374606278.2072.11.camel@bwh-desktop.uk.level5networks.com>
	 <FDC644D3-D724-4D28-A5A2-A11A45F81545@cygnusnetworks.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"Max Krasnyansky" <maxk@qti.qualcomm.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Helmut Grohne <h.grohne@cygnusnetworks.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23806 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310Ab3G3KvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 06:51:24 -0400
In-Reply-To: <FDC644D3-D724-4D28-A5A2-A11A45F81545@cygnusnetworks.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-30 at 08:20 +0200, Helmut Grohne wrote:
> Thanks for your review! Given the v2 patch Stephen Hemminger posted, I
> think that his series is where development should continue.
> 
> On 23.07.2013, at 21:04, Ben Hutchings <bhutchings@solarflare.com> wrote:
> > This is formatted wrongly - needs a space after 'if' and all the
> > continuation lines should be lined up under 'cmd->supported'.
> 
> I am sorry for not having run checkpatch and will try to remember next time.
> 
> >> +               return -EOPNOTSUPP;
> > 
> > EINVAL
> 
> Makes sense, once you are pointed to it.
> 
> > I notice the port type is reported as PORT_TP.  Perhaps that should also
> > be changed to PORT_NONE (in a separate patch)?
> 
> This appears not yet addressed in the v2 patch yet.
> 
> I am not sure how to go on here. Clearly the v2 patch set, is an improvement
> over my initial version. The additional capabilities of changing the reported
> driver and similar aspects appear controversial though. Would it make sense
> to split this into two patch sets to be handled independently?

Yes, I think that would make sense.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
