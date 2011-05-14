From: Bill Fink <billfink@mindspring.com>
Subject: Re: [RFC] ethernet: avoid pre-assigned OUI values in
 random_ether_addr
Date: Sat, 14 May 2011 02:28:25 -0400
Message-ID: <20110514022825.bcd09e14.billfink@mindspring.com>
References: <20110513171729.247b126e@nehalam>
	<1305332905.8149.705.camel@tardy>
	<20110513173213.491c74a1@nehalam>
	<1305333898.8149.715.camel@tardy>
	<1305334848.8149.729.camel@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:45953
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750867Ab1ENG20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2011 02:28:26 -0400
In-Reply-To: <1305334848.8149.729.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 May 2011, Rick Jones wrote:

> > Well, then by a quick glance at
> > http://standards.ieee.org/develop/regauth/oui/oui.txt it looks like
> > there are more to add... (some overlap with your list, I've not checked
> > the entire thing, how the name conflicts should be resolved I've no
> > idea)
> > 
> > raj@tardy:~$ grep ^02- oui.txt 
> > 02-07-01   (hex)		RACAL-DATACOM
> > 02-1C-7C   (hex)		PERQ SYSTEMS CORPORATION
> > 02-60-86   (hex)		LOGIC REPLACEMENT TECH. LTD.
> > 02-60-8C   (hex)		3COM CORPORATION
> > 02-70-01   (hex)		RACAL-DATACOM
> > 02-70-B0   (hex)		M/A-COM INC. COMPANIES
> > 02-70-B3   (hex)		DATA RECALL LTD
> > 02-9D-8E   (hex)		CARDIAC RECORDERS INC.
> > 02-AA-3C   (hex)		OLIVETTI TELECOMM SPA (OLTECO)
> > 02-BB-01   (hex)		OCTOTHORPE CORP.
> > 02-C0-8C   (hex)		3COM CORPORATION
> > 02-CF-1C   (hex)		COMMUNICATION MACHINERY CORP.
> > 02-E6-D3   (hex)		NIXDORF COMPUTER CORPORATION
> > 
> > The ieee's list doesn't have any 52's though.
> 
> It does have some A's though:
> ~$ grep ^.[26AE]- oui.txt 
> [the aforementioned 02's]
> AA-00-00   (hex)		DIGITAL EQUIPMENT CORPORATION
> AA-00-01   (hex)		DIGITAL EQUIPMENT CORPORATION
> AA-00-02   (hex)		DIGITAL EQUIPMENT CORPORATION
> AA-00-03   (hex)		DIGITAL EQUIPMENT CORPORATION
> AA-00-04   (hex)		DIGITAL EQUIPMENT CORPORATION
> 
> which if I've not botched my bits has the locally administered bit set.

The AA addresses are used by DECNET and related protocols.

					-Bill
