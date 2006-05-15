From: Jiri Benc <jbenc@suse.cz>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 15:25:13 +0200
Message-ID: <20060515152513.5095b2d5@griffin.suse.cz>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:36543 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964847AbWEONZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 09:25:16 -0400
To: "Mark Wallis" <mwallis@serialmonkey.com>
In-Reply-To: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 May 2006 22:57:12 +1000, Mark Wallis wrote:
> Currently, in our rt2x00 (using the devicescape stack) we are firing off an
> ACPI event so that the hardware button can be handled in userspace. This
> allows the user to basically do whatever they want when this button is
> pressed - including bringing down the wireless interface. The problem here
> is no distro's currently contain scripts to run from this event so for many
> users it just "doesn't work" without them manually having to write scripts
> to handle the ACPI even themselves.

Distributions will need to accommodate to the way d80211 stack works
anyway, so I see no problem with this.

> B. should we be firing an ACPI event and getting the distro's to add scripts
> so when this event is fired they bring down all the wireless interfaces.

Voting for this. It brings more flexibility.

This is not a problem of your card only. Is there a standard ACPI
rf-kill event?

 Jiri

-- 
Jiri Benc
SUSE Labs
