From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 3/3] vxlan: Remote checksum offload
Date: Mon, 24 Nov 2014 17:06:06 -0800
Message-ID: <CAEP_g=9_6Rq9Ssr_2q4MKfSDxeL23rbExP5ziHbeCL0Nx-VTvw@mail.gmail.com>
References: <1416873150-12260-1-git-send-email-therbert@google.com> <1416873150-12260-4-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:51467 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751139AbaKYBG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 20:06:27 -0500
Received: by mail-qc0-f173.google.com with SMTP id i17so7775145qcy.32
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 17:06:27 -0800 (PST)
In-Reply-To: <1416873150-12260-4-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2014 at 3:52 PM, Tom Herbert <therbert@google.com> wrote:
> Add support for remote checksum offload in VXLAN. This commandeers a
> reserved bit to indicate that RCO is being done, and uses the low order
> reserved eight bits of the VNI to hold the start and offset values in a
> compressed manner.

Why do you think that this is OK for you to do? It's clear that there
is no consensus for this (and in fact there are other proposals that
use that bit in a different way).
