From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] ethernet: avoid pre-assigned OUI values in
 random_ether_addr
Date: Mon, 16 May 2011 07:29:06 -0700
Message-ID: <1305556146.8149.735.camel@tardy>
References: <20110513171729.247b126e@nehalam>
	 <1305332905.8149.705.camel@tardy> <20110513173213.491c74a1@nehalam>
	 <1305333898.8149.715.camel@tardy> <1305334848.8149.729.camel@tardy>
	 <20110514022825.bcd09e14.billfink@mindspring.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:41579 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755553Ab1EPO3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 10:29:19 -0400
In-Reply-To: <20110514022825.bcd09e14.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-05-14 at 02:28 -0400, Bill Fink wrote:
> On Fri, 13 May 2011, Rick Jones wrote:
> 
> > > Well, then by a quick glance at
> > > http://standards.ieee.org/develop/regauth/oui/oui.txt it looks like
> > > there are more to add... (some overlap with your list, I've not checked
> > > the entire thing, how the name conflicts should be resolved I've no
> > > idea)
> > > 
> > > raj@tardy:~$ grep ^02- oui.txt 
> > > 02-07-01   (hex)		RACAL-DATACOM
> > > 02-1C-7C   (hex)		PERQ SYSTEMS CORPORATION
> > > 02-60-86   (hex)		LOGIC REPLACEMENT TECH. LTD.
> > > 02-60-8C   (hex)		3COM CORPORATION
> > > 02-70-01   (hex)		RACAL-DATACOM
> > > 02-70-B0   (hex)		M/A-COM INC. COMPANIES
> > > 02-70-B3   (hex)		DATA RECALL LTD
> > > 02-9D-8E   (hex)		CARDIAC RECORDERS INC.
> > > 02-AA-3C   (hex)		OLIVETTI TELECOMM SPA (OLTECO)
> > > 02-BB-01   (hex)		OCTOTHORPE CORP.
> > > 02-C0-8C   (hex)		3COM CORPORATION
> > > 02-CF-1C   (hex)		COMMUNICATION MACHINERY CORP.
> > > 02-E6-D3   (hex)		NIXDORF COMPUTER CORPORATION
> > > 
> > > The ieee's list doesn't have any 52's though.
> > 
> > It does have some A's though:
> > ~$ grep ^.[26AE]- oui.txt 
> > [the aforementioned 02's]
> > AA-00-00   (hex)		DIGITAL EQUIPMENT CORPORATION
> > AA-00-01   (hex)		DIGITAL EQUIPMENT CORPORATION
> > AA-00-02   (hex)		DIGITAL EQUIPMENT CORPORATION
> > AA-00-03   (hex)		DIGITAL EQUIPMENT CORPORATION
> > AA-00-04   (hex)		DIGITAL EQUIPMENT CORPORATION
> > 
> > which if I've not botched my bits has the locally administered bit set.
> 
> The AA addresses are used by DECNET and related protocols.

Um, ok, I was figuring something along those lines - but regardless, in
the context of Stephen's RFC, they are pre-assigned OUIs with the
locally administered bit set and presumably as such ones that should not
be assigned by the random ethernet address generator.  Assuming that
checking for such things is indeed necessary in the first place.

rick jones

