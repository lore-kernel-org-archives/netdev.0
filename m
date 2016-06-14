From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip route: Add annotation for replaced routes
Date: Tue, 14 Jun 2016 14:34:23 -0700
Message-ID: <20160614143423.5f202e8c@xeon-e3>
References: <1465502742-17289-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36432 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbcFNVeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:34:13 -0400
Received: by mail-pf0-f182.google.com with SMTP id t190so885112pfb.3
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 14:34:12 -0700 (PDT)
In-Reply-To: <1465502742-17289-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Jun 2016 13:05:42 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> If NLM_F_REPLACE flag is set then a route is replacing an existing route.
> Prepend "Replaced " to these routes similar to how "Deleted " is added
> to deleted routes.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Why just routes, there are several other places where Replaced entries could
be returned?
