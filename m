From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH 06/26] atl1: update initialization parameters
Date: Tue, 22 Jan 2008 21:30:49 -0500
Message-ID: <4796A6D9.9040806@redhat.com>
References: <1199152804-3889-1-git-send-email-jacliburn@bellsouth.net>	<1199152804-3889-7-git-send-email-jacliburn@bellsouth.net>	<4795BDBB.10904@garzik.org> <20080122201346.6bb36ca2@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728AbYAWCit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 21:38:49 -0500
In-Reply-To: <20080122201346.6bb36ca2@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> On Tue, 22 Jan 2008 04:56:11 -0500
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>> jacliburn@bellsouth.net wrote:
>>> From: Jay Cliburn <jacliburn@bellsouth.net>
>>>
>>> Update initialization parameters to match the current vendor driver
>>> version 1.2.40.2.
> 
> [...]
> 
>> ACK without any better knowledge...  but is any addition insight 
>> available at all?
> 
> No, sorry Jeff.  I simply took the vendor's current driver and matched
> his initialization settings.  I can only assume he discovered these
> values through lab testing.
> 
> For this and the other "conform to vendor driver" patches in this set, I
> thought it important to have the in-tree driver match the vendor driver
> as closely as possible.  The primary motivations are (1) my belief that
> he's in a better position to test the NIC, and (2) to be able to go to
> him for assistance occasionally and not be rejected because of
> significant differences between his and our drivers.

I don't think we should be doing this without justification.  From all the atl1 
and atl2 code I've looked at, I've gotten the impression that their driver 
development processes are extremely ad-hoc.  There is code in the Atheros 
version of atl2 that cannot *possibly* apply to that hardware and was just 
copied and pasted from atl1, just as much of atl1 was copied and pasted from 
e1000.  The fact that various versions have different magic numbers may simply 
mean they copied and pasted from different irrelevant and incorrect sources.

Our contacts at Atheros seem to be very good electrical engineers, so when they 
tell us that a certain setting should be changed to match particular properties 
of the hardware, I trust them.  They are not, however, experienced and 
disciplined kernel developers, so absent such justification I think we should 
stick with what we have, which has been improved and reviewed by people who 
*are* experienced and disciplined kernel developers.

We have at least as much to teach Atheros about writing kernel code as they have 
to teach us about their hardware.

	-- Chris
