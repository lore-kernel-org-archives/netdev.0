From: Sarah Sharp <sarah.a.sharp@linux.intel.com>
Subject: Re: Help testing for USB ethernet/xHCI regression
Date: Thu, 30 Jan 2014 13:41:33 -0800
Message-ID: <20140130214133.GB14228@xanatos>
References: <22081260.RNay0J72dY@athas>
 <20140129215408.GC5991@xanatos>
 <063D6719AE5E284EB5DD2968C1650D6D0F6ACF20@AcuExch.aculab.com>
 <20140130184412.GA3787@xanatos>
 <A2CA0424C0A6F04399FB9E1CD98E03046D147453@US01WEMBX2.internal.synopsys.com>
 <52EAAF6F.7070202@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Zimmerman <paulz@synopsys.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"renevant@internode.on.net" <renevant@internode.on.net>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mark Lord <mlord@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:23928 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753294AbaA3Vlp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jan 2014 16:41:45 -0500
Content-Disposition: inline
In-Reply-To: <52EAAF6F.7070202@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 03:00:47PM -0500, Mark Lord wrote:
> On 14-01-30 02:54 PM, Paul Zimmerman wrote:
> >
> > Can you give a pointer to where we could buy one of these devices? I
> > would like to test this with our (Synopsys) xHCI controller as well.
> > 
> 
> newegg.com, item N82E16817659005

Ah, so it's also the ASIX AX88179 that's causing you issues.

Mark and David, can you pull the 3.13-td-changes-reverted branch again,
and see if the latest patch fixes your issue?  It disables scatter
gather for the ax88179_178a device, but only when it's operating at USB
3.0 speeds.

Please test with it plugged into a USB 3.0 port, and when it's plugged
in behind a USB 2.0 hub.

Sarah Sharp
