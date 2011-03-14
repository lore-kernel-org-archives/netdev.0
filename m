From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 30952] New: asix driver broken since 2.6.35
Date: Mon, 14 Mar 2011 14:49:54 -0700
Message-ID: <20110314144954.b87fdd64.akpm@linux-foundation.org>
References: <bug-30952-10286@https.bugzilla.kernel.org/>
	<20110314144309.a303662f.akpm@linux-foundation.org>
	<20110314.144553.70194816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, lipski.bogdan@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35721 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753120Ab1CNVuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:50:46 -0400
In-Reply-To: <20110314.144553.70194816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Mar 2011 14:45:53 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Mon, 14 Mar 2011 14:43:09 -0700
> 
> > 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > The reporter says "workaround suggested in:
> > https://bugzilla.kernel.org/show_bug.cgi?id=16831 seems to work well
> > for me as well".  That workaround appears to be "dump the kernel driver
> > and use the driver off the vendor's website".
> 
> This is an issue you've brought up to me several months ago.
> 
> I started looking into it, but because the vendor driver development
> happens in a completely different universe the divergence noise is
> substantial and it's a huge effort to consolidate these two drivers.
> 
> I think that until the vendor starts to care, nothing is going to
> happen to resolve these ASIC driver bugs.

Yup.  I suppose an alternative approach might be to feed the current
vendor driver through the drivers/staging process (preferably with
their assistance!) then run with two alternative drivers for a
while and eventually remove the old one.

But that's without having looked at the vendor code.  Is it a Big Mess?
