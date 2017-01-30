From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] qed: Add infrastructure for PTP support.
Date: Mon, 30 Jan 2017 14:26:19 +0100
Message-ID: <20170130132619.GA4854@localhost.localdomain>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153134.GC2223@localhost.localdomain>
 <BL2PR07MB23065AC5421859AAC6D334348D480@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170129205156.GA30336@localhost.localdomain>
 <BL2PR07MB23063CA6DC624BDC4ABCCC268D480@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:35741 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750801AbdA3NyK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 08:54:10 -0500
Received: by mail-wj0-f193.google.com with SMTP id i7so7865550wjf.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 05:54:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BL2PR07MB23063CA6DC624BDC4ABCCC268D480@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 29, 2017 at 09:36:11PM +0000, Mintz, Yuval wrote:
> I might have gotten it all wrong, but I was under the assumption that time-
> stamped packets are periodic, and that the interval between two isn't
> going to be so small.

That is an incorrect assumption.  Consider the Delay_Req packets
arriving on a port in the MASTER state.

> Is so, how does having a couple of additional instructions in between
> jeopardizes the next time stamp?

It is not just about the few instructions, but there is also
preemption possible.

Thanks,
Richard
