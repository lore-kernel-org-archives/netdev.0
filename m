From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: PROBLEM: usbnet / ax88179_178a: Panic in usb_hcd_map_urb_for_dma
Date: Mon, 13 Jan 2014 12:28:52 +0100
Message-ID: <87zjn086iz.fsf@nemi.mork.no>
References: <CAHNSM4Kv5gcJn=H4k8QjPggWzjF0zRm_t_icAYXjCTqXx4xL2w@mail.gmail.com>
	<1389385824.2025.95.camel@bwh-desktop.uk.level5networks.com>
	<87ob3j1ocb.fsf@nemi.mork.no>
	<CAHNSM4KU8QEybpHgAcCjQoWuRjU8=wd1O7KUVMnrRJKQ-xr=Gg@mail.gmail.com>
	<87zjn3z6d5.fsf@nemi.mork.no>
	<063D6719AE5E284EB5DD2968C1650D6D458FEE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Kear <thomas@kear.co.nz>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40934 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbaAML3K convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 06:29:10 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D458FEE@AcuExch.aculab.com>
	(David Laight's message of "Mon, 13 Jan 2014 11:08:06 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Laight <David.Laight@ACULAB.COM> writes:

> The patch you submitted is wrong.
> Whoever wrote the sg interface was on crack.
> The 'last' marker needs moving as well.

I'm afraid I don't understand what you meant by this.

sg_init_table() set the 'last' marker.  AFAICS, you don't need to chang=
e
it unless you want to chain lists.

Care to explain with some code?


Bj=C3=B8rn
