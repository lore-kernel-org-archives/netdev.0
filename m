From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 3/3] vmxnet3: fix typo setting confPA
Date: Sun, 24 Oct 2010 18:46:27 -0700
Message-ID: <AANLkTi=XUrRsNqCfMsyMQoXj2ufe-RPwrbNJMBTvttvW@mail.gmail.com>
References: <AANLkTinBGP1gzUCFN2n1xBGZydEnUKoZYPKd1_WbF1gY@mail.gmail.com>
	<89E2752CFA8EC044846EB8499819134102BF28D66D@EXCH-MBX-4.vmware.com>
	<AANLkTimy5Pg1aUMfCZG+r+Zb=A_udx8NsYf3TXVHHTsf@mail.gmail.com>
	<20101024.154417.116368884.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sbhatewara@vmware.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57914 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab0JYBq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 21:46:27 -0400
Received: by iwn10 with SMTP id 10so129841iwn.19
        for <netdev@vger.kernel.org>; Sun, 24 Oct 2010 18:46:27 -0700 (PDT)
In-Reply-To: <20101024.154417.116368884.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 24, 2010 at 3:44 PM, David Miller <davem@davemloft.net> wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
>> <sbhatewara@vmware.com> wrote:
>>> Because values need to be written in LE orders in registers. For eg. when rx_ring.next2fill index is written to RXPROD reg, it should be converted from CPU order to LE.
>>
>> Yes, but (unless I'm mistaken) writel always writes out in
>> little-endian, so there isn't a need to swap the arguments,
>> similarly for readl in the other direction.
>
> That's right, readl() and writel() translate to little-endian.
>

OK, I'll submit patches for this and one more endian fix I found (only
visible on BE)

Harvey
