From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 0/3] [RFC] ptp: IEEE 1588 clock support
Date: Thu, 29 Apr 2010 22:30:03 +0200
Message-ID: <4BD9EC4B.5010109@grandegger.com>
References: <20100427091344.GA5086@riccoc20.at.omicron.at> <4BD97573.5050101@grandegger.com> <20100429153401.GA26741@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:46146 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757620Ab0D3Ri4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:38:56 -0400
In-Reply-To: <20100429153401.GA26741@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Richard Cochran wrote:
> On Thu, Apr 29, 2010 at 02:02:59PM +0200, Wolfgang Grandegger wrote:
>> I realized two other netdev drivers already supporting PTP timestamping:
>> igb and bfin_mac. From the PTP developer point of view, the interface
>> looks rather complete to me and it works fine on my MPC8313 setup.
> 
> Do you know whether these two also have PTP clocks? If so, is the API
> that I suggested going to work for controlling those clocks, too?

Well, I don't really know that hardware in detail. I just browsed the
code, e.g:

http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commit;h=38c845c76
http://marc.info/?l=linux-netdev&m=126389931509102&w=2

But I believe that your interface is generic enough to support that
hardware as well. Would make sense to put the relevant people on CC and
also "ptpd@lists.infradead.org."

Wolfgang.
