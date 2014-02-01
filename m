From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Sat, 1 Feb 2014 22:18:42 +0800
Message-ID: <CACVXFVOynsojKo+aukHY4q+MkEyhHXC0=OpN0ysu0TGuUjY8sA@mail.gmail.com>
References: <20140130211816.GB3787@xanatos>
	<87iot1qgv6.fsf@nemi.mork.no>
	<20140130221511.GD14228@xanatos>
	<CACVXFVMVoMAH3DRiv-VYZL8VWq2Rw+fZwreVtUVm1M44HR+X8Q@mail.gmail.com>
	<20140131190035.GB18262@xanatos>
	<CACVXFVN3OsPM5CBWjc4kh_sGo3fMwpvBoYer7VtreUWrvWA=+Q@mail.gmail.com>
	<52ECF6F5.6060207@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	=?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	David Laight <David.Laight@aculab.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Mark Lord <mlord@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:60010 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932797AbaBAOSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Feb 2014 09:18:45 -0500
In-Reply-To: <52ECF6F5.6060207@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 1, 2014 at 9:30 PM, Mark Lord <mlord@pobox.com> wrote:
> On 14-02-01 02:54 AM, Ming Lei wrote:
> ..
>> With SG enabled, for the iperf client test case, the average urb size
>> for transmission will be increased from ~1500 to ~20K bytes in my
>> test case:
>>
>>    iperf -c $SRV -t 30 -P 4 -w 128K
>>
>> So I am wondering you guys do not care the improvement ..
>
> No, that's not it.  Simply, the recent changes killed the driver

I just want to clarify the sg approach does improve performance,
instead of no improvement mentioned by your guys.

> for some users, something Linus calls a "regression", and does not permit.

Even real regressions are easily/often introduced, and we are discussing
how to fix that. I suggest to unset the flag only for the known buggy
controllers.


Thanks,
--
Ming Lei
