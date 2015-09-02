From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2] net: Add table id from route lookup to route
 response
Date: Wed, 2 Sep 2015 22:23:14 +0200
Message-ID: <20150902202314.GC25648@pox.localdomain>
References: <20150902190836.GD20527@pox.localdomain>
 <1441224980-6201-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34825 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932253AbbIBUXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 16:23:18 -0400
Received: by wicge5 with SMTP id ge5so52915642wic.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 13:23:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1441224980-6201-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/15 at 01:16pm, David Ahern wrote:
> IPv4 ABI has the table hardcoded as RT_TABLE_MAIN regardless of the table
> hit for the route lookup. Add the table using a new attribute,
> RTA_TABLE_LOOKUP, to maintain the ABI yet return the right table id.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> 
> Thomas: Something like this?
> 
> The current ABI is returning wrong data in some cases; that seems worse
> to me than breaking the ABI.

Another option is to introduce a new flag bundled with RTM_GETROUTE
which fixes RTM_GETROUTE altogether and makes it return the actual
route instead of a simulated cache entry.
