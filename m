From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Fri, 31 Jan 2014 15:22:37 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B6083@AcuExch.aculab.com>
References: <20140130211816.GB3787@xanatos> <87iot1qgv6.fsf@nemi.mork.no>
 <20140130221511.GD14228@xanatos>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	"Dan Williams" <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Mark Lord <mlord@pobox.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>,
	Ming Lei <ming.lei@canonical.com>
To: 'Sarah Sharp' <sarah.a.sharp@linux.intel.com>,
	=?Windows-1252?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37406 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754047AbaAaPXK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 10:23:10 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08575-05 for <netdev@vger.kernel.org>;
 Fri, 31 Jan 2014 15:23:06 +0000 (GMT)
In-Reply-To: <20140130221511.GD14228@xanatos>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sarah Sharp
> On Thu, Jan 30, 2014 at 10:50:21PM +0100, Bj=F8rn Mork wrote:
> > FWIW, the plan looks fine to me.  Just adding a couple of hints to
> > simplify the implementation.
> >
> > Sarah Sharp <sarah.a.sharp@linux.intel.com> writes:
> >
> > > Let's do this fix the right way, instead of wall papering over th=
e
> > > issue.  Here's what we should do:
> > >
> > > 1. Disable scatter-gather for the ax88179_178a driver when it's u=
nder an
> > >    xHCI host.
> >
> > No need to make this conditional.  SG is only enabled in the
> > ax88179_178a driver if udev->bus->no_sg_constraint is true, so it
> > applies only to xHCI hosts in the first place.

Leave the usbnet code alone and unset udev->bus->no_sg_constraint.

	David
