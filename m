From: Jesse Gross <jesse@kernel.org>
Subject: Re: Extreme slowness in IPIP tunnel when routing through kernel 3.18
 and later
Date: Thu, 17 Mar 2016 11:27:55 -0700
Message-ID: <CAEh+42h0hdNSQDZyHDWHE0qx8bf4AzP0ooaBxPXsj=bf-L5hFQ@mail.gmail.com>
References: <56EAB8F3.7060802@ednet.ns.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Patrick Boutilier <boutilpj@ednet.ns.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:45930 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935988AbcCQS2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 14:28:13 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id D901F201BB
	for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 18:28:11 +0000 (UTC)
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D870320142
	for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 18:28:10 +0000 (UTC)
Received: by mail-qg0-f41.google.com with SMTP id a36so47895349qge.0
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 11:28:10 -0700 (PDT)
In-Reply-To: <56EAB8F3.7060802@ednet.ns.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2016 at 7:02 AM, Patrick Boutilier <boutilpj@ednet.ns.ca> wrote:
> I have an IPIP tunnel setup between two hosts in different buildings. The
> Linux router they route through causes extreme slowness in the tunnel when
> running kernels from 3.18 on . tcpdump shows many cksum errors which don't
> show up in the 3.17 and earlier kernels. Speed goes back to normal when
> rx-checksumming and tx-checksumming are turned off using ethtool on the
> Linux router . Would this be an effect of bulk network packet transmission
> that was introduced in 3.18 or some other issue?

I just sent out a likely fix, would you mind testing it?
https://patchwork.ozlabs.org/patch/599213/
