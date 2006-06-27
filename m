From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: Labeled Networking Requirements and Design (formerly RE: [PAT
	CH 01/06] MLSXFRM: Granular IPSec associations for use in  MLS environmen
	ts)
Date: Tue, 27 Jun 2006 11:29:12 -0400
Message-ID: <36282A1733C57546BE392885C061859201324767@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, davem@davemloft.net,
	sds@tycho.nsa.gov, paul.moore@hp.com, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:15628 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161104AbWF0PaA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 11:30:00 -0400
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > 5. Patch for ITEM7: TCS currently have no plans to design 
> and implement this.
> > 
> 
> (Datagram labeling)
> 
> I guess we'd probably use SCM_SECURITY for this (similar to 
> IP_CMSG_PASSEC for receiving the label).

Seems like a logical way to do it.
> 
> Is this enough support for user API support at the kernel 
> level in terms 
> of setting and getting labels?

Actually I missed mentioning the following under User API:

4. iptables contexts
   a. Specify labels with iptables rules.

Can't think of anything else being needed at this point in time.

Also, for the sake of the discussion, one "requirement" that some
may have is "Label-based routing", which would basically be a
polyinstantiated routing table. This is something TCS is currently
not interested in pursuing.

So, under USER REQUIREMENTS:

4. Routing support

	a. provision for a label-based routing mechanism (aka
polyinstantiated
	   routing table).
