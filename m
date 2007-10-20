From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state()
 function
Date: Fri, 19 Oct 2007 18:12:03 -0700
Message-ID: <1192842723.5369.23.camel@dell>
References: <1192829817.22064.559.camel@teletran1>
 <20071019232926.GL29903@austin.ibm.com> <1192840577.5369.9.camel@dell>
 <20071020000421.GO29903@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Matt Carlson" <mcarlson@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>,
	linux-pci@atrey.karlin.mff.cuni.cz
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3989 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751310AbXJTAPU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 20:15:20 -0400
In-Reply-To: <20071020000421.GO29903@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-10-19 at 19:04 -0500, linas@austin.ibm.com wrote:
> I'm working in linux-2.6.23-rc8-mm1 at the moment, and I don't see
> that happening. viz. read_msi_msg() is not called anywhere, and I need
> to have valid msg->address_lo and msg->address_hi and msg->data
> in order to be able to restore.
> 
> In particular, this has to happen after the call to
> arch_setup_msi_irqs
> as otherwise, the arch hasn't yet filled these fields with correct
> values.
> 
> Perhaps this is fixed in the kernel you're working with?

It's possible that this doesn't work on pseries.  I've only tested
pci_restore_msi_state() on x86 in the context of suspend and resume.
During resume, the MSI state gets restored correctly on x86.

