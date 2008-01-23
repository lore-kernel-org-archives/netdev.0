From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 06/26] atl1: update initialization parameters
Date: Tue, 22 Jan 2008 21:19:23 -0500
Message-ID: <4796A42B.6090501@garzik.org>
References: <1199152804-3889-1-git-send-email-jacliburn@bellsouth.net>	<1199152804-3889-7-git-send-email-jacliburn@bellsouth.net>	<4795BDBB.10904@garzik.org> <20080122201346.6bb36ca2@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40964 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751602AbYAWCT1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 21:19:27 -0500
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

Since these changes are not simply moving code around, we really do need 
full explanations for them, and to understand their need.

Blindly copying code from an exterior driver is pointless, and no way at 
all to run an engineering process.

If the driver is not going to get the review and attention necessary, 
bug fixes and feedback attended-to, then there's not much point in 
having this driver in the kernel at all.

You will only lead yourself to frustration, if you set up a system where 
changes only flow one way.  That's not how Linux development is done at all.

	Jeff



