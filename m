From: Andi Kleen <andi@firstfloor.org>
Subject: Re: a maze of twisty stats, most different
Date: 29 Jun 2007 19:30:23 +0200
Message-ID: <p73abui4qj4.fsf@bingen.suse.de>
References: <4683F10F.6070007@hp.com>
	<OF4B8149B6.D8E6CC86-ON88257308.006345F0-88257308.0064762A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, Chris Snook <csnook@redhat.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39984 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753157AbXF2Qet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 12:34:49 -0400
In-Reply-To: <OF4B8149B6.D8E6CC86-ON88257308.006345F0-88257308.0064762A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens <dlstevens@us.ibm.com> writes:

> I think there's a more general problem that's a huge hassle. There are 
> lots of
> new SNMP MIB's, but no conventions (that I'm aware of, at least) to allow 
> for
> changes to the /proc entries that get them to applications. 

Actually /proc/net/snmp and netstat -s are extensible. If you add a new
MIB or field there it should just show up in netstat -s. It won't know about
the text decoding that is done for the early traditional MIBs, but that
is already not there for most of the newer fields.

-Andi
