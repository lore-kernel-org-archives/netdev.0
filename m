From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 21:32:47 +0200
Message-ID: <200605152132.47883.mb@bu3sch.de>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com> <200605151801.06379.mb@bu3sch.de> <1147720370.3067.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:58605
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751597AbWEOTdp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 15:33:45 -0400
To: Dan Williams <dcbw@redhat.com>, Jason Lunz <lunz@falooley.org>,
	netdev@vger.kernel.org
In-Reply-To: <1147720370.3067.14.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 15 May 2006 21:12, you wrote:
> > There are registers on the bcm43xx chip (0x158 and 0x49A) that indicate
> > some "Radio is hardware-disabled" state. We currently don't use that flag
> > correctly in the driver. Could you please assist me on testing if your switch
> > actually toggles the bit?
> > I think best place for this would be on irc.freenode.net #bcm-users
> 
> When those bits get set in the register, is the radio already disabled?
> ie, for the bcm43xx chip, is it really force-disabled by the button, or
> does the driver have some control?

Hm, actually, We don't know what the bit means. Could be some
completely different meaning. That is what I am trying to find
out. But it seems to have something to do with the power control
of the chip.
