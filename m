From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] dp83640: Make use of skb_queue_purge instead of
 reimplementing the code
Date: Mon, 8 Sep 2014 21:05:56 +0200
Message-ID: <20140908190555.GA15703@localhost.localdomain>
References: <20140908152226.4202.72383.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:36792 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753060AbaIHTGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 15:06:01 -0400
Received: by mail-we0-f171.google.com with SMTP id x48so2612097wes.16
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 12:06:00 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140908152226.4202.72383.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 08, 2014 at 11:25:34AM -0400, Alexander Duyck wrote:
> This change makes it so that dp83640_remove can use skb_queue_purge
> instead of looping through itself to flush any entries out of the queue.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
