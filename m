From: Jason Lunz <lunz@falooley.org>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 15:46:14 -0400
Message-ID: <20060515194614.GB25683@knob.reflex>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com> <e4a6lq$g5v$1@sea.gmane.org> <200605151801.06379.mb@bu3sch.de> <1147720370.3067.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.reflexsecurity.com ([72.54.64.74]:54690 "EHLO
	crown.reflexsecurity.com") by vger.kernel.org with ESMTP
	id S964949AbWEOTqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 15:46:18 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1147720370.3067.14.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2006 at 03:12:50PM -0400, Dan Williams wrote:
> When those bits get set in the register, is the radio already disabled?
> ie, for the bcm43xx chip, is it really force-disabled by the button, or
> does the driver have some control?

I assume it disables the radio without any help from the driver, because
it definitely turns off my radio, but the bcm43xx driver i'm using (in
2.6.17-rc4) currently doesn't pay any attention to those registers
afaik.

Jason
