From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Wed, 28 Apr 2010 15:50:47 +0200
Message-ID: <4BD83D37.4060301@grandegger.com>
References: <20100427091344.GA5086@riccoc20.at.omicron.at> <20100427102025.GA6471@riccoc20.at.omicron.at> <4BD6E837.2040505@grandegger.com> <4BD70EC9.7080004@grandegger.com> <20100428054706.GA4516@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:48424 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab0D1Nwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 09:52:37 -0400
In-Reply-To: <20100428054706.GA4516@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:
> On Tue, Apr 27, 2010 at 06:20:25PM +0200, Wolfgang Grandegger wrote:
>> Do you have also a patch adding support for hardware timestamping to ptpd?
> 
> Yes, I do:
> 
>    https://sourceforge.net/tracker/index.php?func=detail&aid=2992847&group_id=139814&atid=744634

Thanks.

> I should have mentioned, you also need the gianfar HW time stamping
> patches, recently posted to netdev by Manfred Rudigier.

I'm aware of these patches. I'm actually using the net-next-2.6 git tree.

I got ptpd working but I do not yet see the PPS-Signals on my scope. At
a first glance, the PPS-Signal seems to be configured by the gianfar_ptp
driver (setting the fiper1 and timer1 registers) but I might have missed
something.

Wolfgang.
