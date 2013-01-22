From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net 3/3] net: cdc_ncm: fix error path for single interface probing
Date: Tue, 22 Jan 2013 11:32:14 +0100
Message-ID: <87ip6pa4pd.fsf@nemi.mork.no>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
	<1358783440-11459-4-git-send-email-bjorn@mork.no>
	<2830395.rGXyQGCbQc@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53864 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752439Ab3AVKdD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 05:33:03 -0500
In-Reply-To: <2830395.rGXyQGCbQc@linux-5eaq.site> (Oliver Neukum's message of
	"Tue, 22 Jan 2013 09:58:05 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> writes:
> On Monday 21 January 2013 16:50:40 Bj=C3=B8rn Mork wrote:
>> commit bbc8d92 (net: cdc_ncm: add Huawei devices) implemented
>> support for devices with a single combined control and data
>> interface. Fix up the error path so that we do not double
>> release such interfaces in case of probing failures.
>
> Hi Bj=C3=B8rn,
>
> this should go also into stable. Could you submit?

Yes, it should.  But AFAIK David prefers to do the stable submissions
for net, including drivers/net/usb.


Bj=C3=B8rn
