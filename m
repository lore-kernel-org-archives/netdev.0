From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 18:01:06 +0200
Message-ID: <200605151801.06379.mb@bu3sch.de>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com> <e4a6lq$g5v$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:51594
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751589AbWEOQBu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 12:01:50 -0400
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <e4a6lq$g5v$1@sea.gmane.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 15 May 2006 17:27, you wrote:
> mwallis@serialmonkey.com said:
> > Some people are saying that instead of throwing and ACPI event we should be
> > either use hotplug or internally just disable the radio and somehow inform
> > the dscape stack that the radio has been disabled.
> >
> > What are peoples thoughts here, should we 
> >
> > A. be handling this within our drivers and doing "what the user expects" and
> > disabling the hardware radio, or 
> 
> On my HP laptop with bcm43xx wireless, the button disables the radio in
> HARDWARE, and afaict the driver has no idea about it. The driver notices
> that it's not connected and happily starts scanning again, unaware that
> anything is wrong.

There are registers on the bcm43xx chip (0x158 and 0x49A) that indicate
some "Radio is hardware-disabled" state. We currently don't use that flag
correctly in the driver. Could you please assist me on testing if your switch
actually toggles the bit?
I think best place for this would be on irc.freenode.net #bcm-users
