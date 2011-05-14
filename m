From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] ethernet: avoid pre-assigned OUI values in
 random_ether_addr
Date: Fri, 13 May 2011 17:44:58 -0700
Message-ID: <1305333898.8149.715.camel@tardy>
References: <20110513171729.247b126e@nehalam>
	 <1305332905.8149.705.camel@tardy>  <20110513173213.491c74a1@nehalam>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:8107 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759767Ab1ENAo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 20:44:59 -0400
In-Reply-To: <20110513173213.491c74a1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-05-13 at 17:32 -0700, Stephen Hemminger wrote:
> On Fri, 13 May 2011 17:28:25 -0700
> Rick Jones <rick.jones2@hp.com> wrote:
> 
> > On Fri, 2011-05-13 at 17:17 -0700, Stephen Hemminger wrote:
> > > There are some addresses in the assigned vendor block that don't obey
> > > the locally assigned convention. These should be avoided by random_ether_addr
> > > assignment.
> > 
> > How "recent" are these violations?  Is there really a non-trivial chance
> > of colliding?  Much more than two or more stations in the same broadcast
> > domain randomly picking the same random MAC anyway?
> > 
> > At one level, avoiding using those OUIs seems to be a tacit approval of
> > the violations.
> 
> These were assigned long ago in the early days of Ethernet.
> It makes sense to me to avoid them as just good policy.


Well, then by a quick glance at
http://standards.ieee.org/develop/regauth/oui/oui.txt it looks like
there are more to add... (some overlap with your list, I've not checked
the entire thing, how the name conflicts should be resolved I've no
idea)

raj@tardy:~$ grep ^02- oui.txt 
02-07-01   (hex)		RACAL-DATACOM
02-1C-7C   (hex)		PERQ SYSTEMS CORPORATION
02-60-86   (hex)		LOGIC REPLACEMENT TECH. LTD.
02-60-8C   (hex)		3COM CORPORATION
02-70-01   (hex)		RACAL-DATACOM
02-70-B0   (hex)		M/A-COM INC. COMPANIES
02-70-B3   (hex)		DATA RECALL LTD
02-9D-8E   (hex)		CARDIAC RECORDERS INC.
02-AA-3C   (hex)		OLIVETTI TELECOMM SPA (OLTECO)
02-BB-01   (hex)		OCTOTHORPE CORP.
02-C0-8C   (hex)		3COM CORPORATION
02-CF-1C   (hex)		COMMUNICATION MACHINERY CORP.
02-E6-D3   (hex)		NIXDORF COMPUTER CORPORATION

The ieee's list doesn't have any 52's though.

rick

