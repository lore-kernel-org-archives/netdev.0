From: Mark Lord <mlord@pobox.com>
Subject: Re: [PATCH RFC 1/1] usb: Tell xhci when usb data might be misaligned
Date: Sat, 01 Feb 2014 08:30:29 -0500
Message-ID: <52ECF6F5.6060207@pobox.com>
References: <20140130211816.GB3787@xanatos>	<87iot1qgv6.fsf@nemi.mork.no>	<20140130221511.GD14228@xanatos>	<CACVXFVMVoMAH3DRiv-VYZL8VWq2Rw+fZwreVtUVm1M44HR+X8Q@mail.gmail.com>	<20140131190035.GB18262@xanatos> <CACVXFVN3OsPM5CBWjc4kh_sGo3fMwpvBoYer7VtreUWrvWA=+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>,
	David Laight <David.Laight@aculab.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Williams <dan.j.williams@intel.com>,
	"Nyman, Mathias" <mathias.nyman@intel.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: Ming Lei <ming.lei@canonical.com>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:44690 "EHLO
	sasl.smtp.pobox.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932830AbaBANah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Feb 2014 08:30:37 -0500
In-Reply-To: <CACVXFVN3OsPM5CBWjc4kh_sGo3fMwpvBoYer7VtreUWrvWA=+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-02-01 02:54 AM, Ming Lei wrote:
..
> With SG enabled, for the iperf client test case, the average urb size
> for transmission will be increased from ~1500 to ~20K bytes in my
> test case:
> 
>    iperf -c $SRV -t 30 -P 4 -w 128K
> 
> So I am wondering you guys do not care the improvement ..

No, that's not it.  Simply, the recent changes killed the driver
for some users, something Linus calls a "regression", and does not permit.

Far better to have it continue to work than not to work.
The plan discussed earlier calls for reintroduction of SG here
once the problems are solved outside of the main tree.
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
