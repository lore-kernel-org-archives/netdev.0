From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc/netem: loss gemodel options fixes
Date: Thu, 15 May 2014 14:03:34 -0700
Message-ID: <20140515140334.3724578f@nehalam.linuxnetplumber.net>
References: <29682.1399754098@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netem@lists.linux-foundation.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:57813 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaEOVDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 17:03:40 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so1576404pab.10
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 14:03:40 -0700 (PDT)
In-Reply-To: <29682.1399754098@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 10 May 2014 13:34:58 -0700
Jay Vosburgh <jay.vosburgh@canonical.com> wrote:

> 
> 	First, the default value for 1-k is documented as being 0, but is
> currently being set to 1. (100%).  This causes all packets to be dropped
> in the good state if 1-k is not explicitly specified.  Fix this by setting
> the default to 0.
> 
> 	Second, the 1-h option is parsed correctly, however, the kernel is
> expecting "h", not 1-h.  Fix this by inverting the "1-h" percentage before
> sending to and after receiving from the kernel.  This does change the
> behavior, but makes it consistent with the netem documentation and the
> literature on the Gilbert-Elliot model, which refer to "1-h" and "1-k,"
> not "h" or "k" directly.
> 
> 	Last, fix a minor formatting issue for the options reporting.
> 
> Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

Could you get review of original author of this loss model?
  Stefano Salsano <stefano.salsano@uniroma2.it>
