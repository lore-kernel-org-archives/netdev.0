From: Arthur Jones <arthur.jones@riverbed.com>
Subject: Re: [PATCH] e1000e: workaround missing power down mii control bit
 on 82571
Date: Mon, 20 Dec 2010 07:33:01 -0800
Message-ID: <20101220153301.GV18990@ajones-laptop.nbttech.com>
References: <20101216182847.GA14985@ajones-laptop.nbttech.com>
 <1292525797.3253.8.camel@bwh-desktop>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7655@orsmsx509.amr.corp.intel.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F76C4@orsmsx509.amr.corp.intel.com>
 <20101216200425.GO18990@ajones-laptop.nbttech.com>
 <20101216221421.GR18990@ajones-laptop.nbttech.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7AD6@orsmsx509.amr.corp.intel.com>
 <20101217140453.GS18990@ajones-laptop.nbttech.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7BFC@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([208.70.196.45]:24317 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754427Ab0LTPdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 10:33:03 -0500
Content-Disposition: inline
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A9001773F7BFC@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bruce, ...

On Fri, Dec 17, 2010 at 07:53:08AM -0800, Allan, Bruce W wrote:
> >-----Original Message-----
> >From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> >Behalf Of Arthur Jones
> >Sent: Friday, December 17, 2010 6:05 AM
> >To: Allan, Bruce W
> >Cc: Ben Hutchings; Kirsher, Jeffrey T; netdev@vger.kernel.org
> >Subject: Re: [PATCH] e1000e: workaround missing power down mii control bit on
> >82571
> >
> >That's not what I saw.  I saw the bit always
> >read back zero, even right after I set it.
> >
> >Have you tried writing the power down bit and
> >reading it back?
> >
> >Arthur
> 
> Yes, and it worked as expected.

Interesting!  So then you're not able to
repro the issue that I describe in the
patch then either?

This was an 82571?  Can you send along
the firmware revision and the full lspci
for the NIC where it works to read back
the power down bit?  Very strange...

Arthur

