From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v2 3/4] ptp: Add PTP_PF_PPS enumeration to
 ptp_pin_function.
Date: Mon, 29 Sep 2014 15:25:51 +0200
Message-ID: <20140929132551.GA27428@netboy>
References: <1411878011-21767-1-git-send-email-b45643@freescale.com>
 <1411878011-21767-4-git-send-email-b45643@freescale.com>
 <20140929085613.GA9891@netboy>
 <ee73b9239ea9417e976fdf2c51b2fd60@BY2PR03MB441.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: "luwei.zhou@freescale.com" <luwei.zhou@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:60284 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936AbaI2NZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 09:25:57 -0400
Received: by mail-we0-f179.google.com with SMTP id u56so5042553wes.24
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 06:25:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ee73b9239ea9417e976fdf2c51b2fd60@BY2PR03MB441.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2014 at 09:38:44AM +0000, luwei.zhou@freescale.com wrote:
> My understanding is n_pins should be 1 because there is only one PPS output 

The field 'n_pins' is the number of *physical* *programmable* pins.

If the PPS signal on your SoC can appear on any of 4 different pins,
then n_pins should be 4.

If the PPS signal on your SoC can only appear on one pin,
then n_pins should be 0 (zero).

Please see:

 Documentation/ptp/testptp.c
 include/linux/ptp_clock_kernel.h
 include/uapi/linux/ptp_clock.h

Thanks,
Richard
