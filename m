From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute PATCH v4 4/5] No need to initialize rtattr fields before
 parsing
Date: Fri, 15 Jul 2016 09:33:44 -0600
Message-ID: <ae3b0bbc-5886-3371-d946-18cb66e9442e@cumulusnetworks.com>
References: <1468435639-6892-1-git-send-email-phil@nwl.cc>
 <1468435639-6892-5-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>,
	David Laight <David.Laight@ACULAB.COM>, netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>, Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34653 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbcGOPdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 11:33:46 -0400
Received: by mail-io0-f177.google.com with SMTP id q83so107674591iod.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 08:33:46 -0700 (PDT)
In-Reply-To: <1468435639-6892-5-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/13/16 12:47 PM, Phil Sutter wrote:
> Since parse_rtattr_flags() calls memset already, there is no need for
> callers to do so themselves.
>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/ipaddress.c | 2 +-
>  tc/tc_class.c  | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)


Acked-by: David Ahern <dsa@cumulusnetworks.com>
