From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] Fix e1000e with Intel 82572EI that has no hardware timestamp
 support
Date: Wed, 06 Aug 2014 18:30:07 +0400
Message-ID: <53E23BEF.9030701@cogentembedded.com>
References: <be459158bb5c46fcaf73129858342da4@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>,
	Nick Krause <xerofoify@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:47758 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755183AbaHFOaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 10:30:10 -0400
Received: by mail-la0-f42.google.com with SMTP id pv20so2104904lab.29
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 07:30:08 -0700 (PDT)
In-Reply-To: <be459158bb5c46fcaf73129858342da4@FE-MBX1012.de.bosch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/6/2014 6:27 PM, Koehrer Mathias (ETAS/ESW5) wrote:

> With the Intel 82527EI (driver: e1000e) there is an issue when running
> the ptpd2 program, that leads to a kernel oops.
> The reason is here that in e1000_xmit_frame() a work queue will be
> scheduled that has not been initialized in this case.
> The work queue "tx_hwstamp_work" will only be initialized if
> adapter->flags & FLAG_HAS_HW_TIMESTAMP set.
> This check is missing in e1000_xmit_frame().

> The following patch adds the missing check.

    OK, but this time you forgot your sign-off. :-)

WBR, Sergei
