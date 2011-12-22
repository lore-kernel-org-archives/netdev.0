From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH, v2] Xen: consolidate and simplify struct
 xenbus_driver instantiation
Date: Thu, 22 Dec 2011 11:51:46 +0000
Message-ID: <4EF327E2020000780006993E@nat28.tlf.novell.com>
References: <4EF3018D020000780006986E@nat28.tlf.novell.com>
 <1324547820.7877.71.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Konrad Rzeszutek Wilk" <konrad@darnok.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"dmitry.torokhov@gmail.com" <dmitry.torokhov@gmail.com>,
	"FlorianSchandinat@gmx.de" <FlorianSchandinat@gmx.de>,
	"Jeremy Fitzhardinge" <jeremy@goop.org>,
	"Jens Axboe" <axboe@kernel.dk>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ian Campbell" <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:34228 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752469Ab1LVLuz convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:10:2>);
	Thu, 22 Dec 2011 06:50:55 -0500
In-Reply-To: <1324547820.7877.71.camel@zakaz.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 22.12.11 at 10:57, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> On Thu, 2011-12-22 at 09:08 +0000, Jan Beulich wrote:
>> The 'name', 'owner', and 'mod_name' members are redundant with the
>> identically named fields in the 'driver' sub-structure. Rather than
>> switching each instance to specify these fields explicitly, introduce
>> a macro to simplify this.
>> 
>> Eliminate further redundancy by allowing the drvname argument to
>> DEFINE_XENBUS_DRIVER() to be blank (in which case the first entry from
>> the ID table will be used for .driver.name).
> 
> Any reason not to always use DRV_NAME here (which is generally a bit
> more specific e.g. "xen-foofront" rather than "foo") and rely on the id
> table for the shorter names used in xenstore?

That would imply that DRV_NAME is always defined, but I don't
see this being the case.

Jan
