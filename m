From: Dan Williams <dcbw@redhat.com>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 15:12:50 -0400
Message-ID: <1147720370.3067.14.camel@localhost.localdomain>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com>
	 <e4a6lq$g5v$1@sea.gmane.org>  <200605151801.06379.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jason Lunz <lunz@falooley.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37594 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751631AbWEOTOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 15:14:45 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200605151801.06379.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-05-15 at 18:01 +0200, Michael Buesch wrote:
> On Monday 15 May 2006 17:27, you wrote:
> > mwallis@serialmonkey.com said:
> > > Some people are saying that instead of throwing and ACPI event we should be
> > > either use hotplug or internally just disable the radio and somehow inform
> > > the dscape stack that the radio has been disabled.
> > >
> > > What are peoples thoughts here, should we 
> > >
> > > A. be handling this within our drivers and doing "what the user expects" and
> > > disabling the hardware radio, or 
> > 
> > On my HP laptop with bcm43xx wireless, the button disables the radio in
> > HARDWARE, and afaict the driver has no idea about it. The driver notices
> > that it's not connected and happily starts scanning again, unaware that
> > anything is wrong.
> 
> There are registers on the bcm43xx chip (0x158 and 0x49A) that indicate
> some "Radio is hardware-disabled" state. We currently don't use that flag
> correctly in the driver. Could you please assist me on testing if your switch
> actually toggles the bit?
> I think best place for this would be on irc.freenode.net #bcm-users

When those bits get set in the register, is the radio already disabled?
ie, for the bcm43xx chip, is it really force-disabled by the button, or
does the driver have some control?

Dan


