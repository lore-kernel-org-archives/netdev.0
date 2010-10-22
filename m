From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 3/3] vmxnet3: fix typo setting confPA
Date: Fri, 22 Oct 2010 10:52:15 -0700
Message-ID: <AANLkTimy5Pg1aUMfCZG+r+Zb=A_udx8NsYf3TXVHHTsf@mail.gmail.com>
References: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
	<1287720334-15469-3-git-send-email-harvey.harrison@gmail.com>
	<alpine.LRH.2.00.1010221030530.9726@sbhatewara-dev1.eng.vmware.com>
	<AANLkTinBGP1gzUCFN2n1xBGZydEnUKoZYPKd1_WbF1gY@mail.gmail.com>
	<89E2752CFA8EC044846EB8499819134102BF28D66D@EXCH-MBX-4.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60994 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758199Ab0JVRwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 13:52:16 -0400
Received: by iwn34 with SMTP id 34so1192407iwn.19
        for <netdev@vger.kernel.org>; Fri, 22 Oct 2010 10:52:15 -0700 (PDT)
In-Reply-To: <89E2752CFA8EC044846EB8499819134102BF28D66D@EXCH-MBX-4.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 22, 2010 at 10:46 AM, Shreyas Bhatewara
<sbhatewara@vmware.com> wrote:
>> From: Harvey Harrison [mailto:harvey.harrison@gmail.com]
>> One question I had when looking into this, why are you doing
>> byteswapping in the VMXNET_{READ,WRITE}_BAR{0,1}
>> macros?
>
> Because values need to be written in LE orders in registers. For eg. when rx_ring.next2fill index is written to RXPROD reg, it should be converted from CPU order to LE.

Yes, but (unless I'm mistaken) writel always writes out in
little-endian, so there isn't a need to swap the arguments,
similarly for readl in the other direction.

You wouldn't notice this on a little-endian machine obviously, has
this even bee tried on be?

Harvey
