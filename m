From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] net-timestamp: Make the clone operation
 stand-alone from phy timestamping
Date: Wed, 03 Sep 2014 19:22:02 -0700
Message-ID: <5407CCCA.1060401@gmail.com>
References: <20140903233447.7517.52329.stgit@ahduyck-bv4.jf.intel.com> <20140903233911.7517.59378.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:40623 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098AbaIDCWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 22:22:06 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so12329763pdj.4
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 19:22:01 -0700 (PDT)
In-Reply-To: <20140903233911.7517.59378.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2014 04:42 PM, Alexander Duyck wrote:
> The phy timestamping takes a different path than the regular timestamping
> does in that it will create a clone first so that the packets needing to be
> timestamped can be placed in a queue, or the context block could be used.
>
> In order to support these use cases I am pulling the core of the code out
> so it can be used in other drivers beyond just phy devices.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

This patch can be ignored.  I need to submit a v3 with some fixes for
socket accounting.

Thanks,

Alex
