From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next v2] ip: route: add congestion control
 metric
Date: Wed, 7 Jan 2015 15:06:57 -0800
Message-ID: <20150107150657.1defa6bd@urahara>
References: <1420630098-21621-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:46924 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755223AbbAGXHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2015 18:07:07 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so7749061pad.13
        for <netdev@vger.kernel.org>; Wed, 07 Jan 2015 15:07:06 -0800 (PST)
In-Reply-To: <1420630098-21621-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Jan 2015 12:28:18 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> +			if (i != RTAX_CC_ALGO)
> +				val = *(unsigned *)RTA_DATA(mxrta[i]);

Please use rta_getattr_u32 here.

Yes, I know you copied old code, but the old code predated the helper
functions.
