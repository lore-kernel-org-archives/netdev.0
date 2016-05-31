From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Added support for selection of new HSR version
Date: Tue, 31 May 2016 12:06:45 -0700
Message-ID: <20160531120645.2614e8af@xeon-e3>
References: <20160530133207.GA5071@aircraft-controller>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peter.heise@airbus.com
To: Peter Heise <mail@pheise.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33414 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcEaTGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 15:06:35 -0400
Received: by mail-pf0-f181.google.com with SMTP id b124so77147886pfb.0
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 12:06:35 -0700 (PDT)
In-Reply-To: <20160530133207.GA5071@aircraft-controller>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 May 2016 15:32:07 +0200
Peter Heise <mail@pheise.de> wrote:

> A new HSR version was added in 4.7 that can be enabled
> via iproute2. Per default the old version is selected,
> however, with "ip link add [..] type hsr [..] version 1"
> the newer version can be enabled.
> 
> Signed-off-by: Peter Heise <peter.heise@airbus.com>
> ---

I fixed two things in this patch.
 1) Don't use ALL CAPS in the error message
 2) Indentation was all messed up and line was too long.

Please use checkpatch in future to check your submissions.
