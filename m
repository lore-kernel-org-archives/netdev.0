From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] qede: Add driver support for PTP.
Date: Tue, 31 Jan 2017 18:43:27 +0100
Message-ID: <20170131174327.GA21731@localhost.localdomain>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153536.GD2223@localhost.localdomain>
 <063D6719AE5E284EB5DD2968C1650D6DB0273BA8@AcuExch.aculab.com>
 <BL2PR07MB2306B5963EBDEF0AF5CD4E8F8D4B0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <063D6719AE5E284EB5DD2968C1650D6DB02749AC@AcuExch.aculab.com>
 <BL2PR07MB23068B30A71CB67A8DE673E48D4A0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170131145318.GA18274@localhost.localdomain>
 <BL2PR07MB23069DF93C3944BAB27F807F8D4A0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@ACULAB.COM>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:34628 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751693AbdAaRnb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 12:43:31 -0500
Received: by mail-wj0-f196.google.com with SMTP id ip10so11582678wjb.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 09:43:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <BL2PR07MB23069DF93C3944BAB27F807F8D4A0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 03:08:11PM +0000, Mintz, Yuval wrote:
> While it surely answers my question, I still don't think of an event
> reoccurring 16 times a second as optimization-crucial.
> Is there any reasonable scenario where the interval is
> significantly smaller, or is it merely some theoretical specification?

Its theoretical, like ipv6 addresses.

> [I'd like to see the machine that can handle the 2^(-128) sec interval]

;)
 
> Again, I don't see how we can achieve that given that qede has to check
> Its internal state to check whether it's right to utilize the ptp-related hw
> configurations and only then call the qed function. As qed can't do it for
> qede, we can't directly map qed's function into the ptp_clock_info,
> but rather have to call it after taking qede's state-lock.

Fair enough.

Thanks,
Richard
