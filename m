From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute:  Support cross-compiling.
Date: Tue, 15 Nov 2011 17:17:22 -0800
Message-ID: <20111115171722.02fa1c77@nehalam.linuxnetplumber.net>
References: <1321405482-18445-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46467 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932791Ab1KPBR3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 20:17:29 -0500
In-Reply-To: <1321405482-18445-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Nov 2011 17:04:42 -0800
greearb@candelatech.com wrote:

> From: Ben Greear <greearb@candelatech.com>
> 
> This lets users use their own compiler instead of
> hard-coding to use gcc.
> 
> Also adds tests to disable some things that were not supported
> in my ARM cross-compile toolchain.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Can't you do this by setting up the compile environment better?
I would rather have the tools work with all features and handle
errors from kernel rather than neutering it.
