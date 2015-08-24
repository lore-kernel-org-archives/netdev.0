From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] inetpeer: Add support for VRFs
Date: Mon, 24 Aug 2015 02:15:14 +0200
Message-ID: <20150824001514.GD21926@pox.localdomain>
References: <1440339964-16075-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35379 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbbHXAPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 20:15:17 -0400
Received: by wicne3 with SMTP id ne3so57558917wic.0
        for <netdev@vger.kernel.org>; Sun, 23 Aug 2015 17:15:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1440339964-16075-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/15 at 08:26am, David Ahern wrote:
> inetpeer caches based on address only, so duplicate IP addresses within
> a namespace return the same cached entry. Similar to IP fragments handle
> duplicate addresses across VRFs by adding the VRF master device index to
> the lookup.

We have a lot of other places which use the address only. Are you
going to add the VRF id to all these places as well?
