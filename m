From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 0/4] remove deprecated syststamp
Date: Sat, 26 Jul 2014 09:45:47 +0200
Message-ID: <20140726074545.GA4472@netboy>
References: <1406325692-616-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	kreese@caviumnetworks.com, ddaney@caviumnetworks.com,
	dborkman@redhat.com, jdmason@kudzu.us
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:49966 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbaGZHp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2014 03:45:59 -0400
Received: by mail-wi0-f173.google.com with SMTP id f8so2045510wiw.6
        for <netdev@vger.kernel.org>; Sat, 26 Jul 2014 00:45:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1406325692-616-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2014 at 06:01:28PM -0400, Willem de Bruijn wrote:
> The remaining driver (octeon) does not expose such a standard
> interface as of now. It does have its own PTP library that depends
> on its own shared memory PTP clock interface.

FWIW, that custom interface isn't even part of the kernel. It was nice
of you to take the trouble to find out about it, and it seems that
removing the SYS time stamp will not hurt applications using the
custom interface. They will need a custom kernel in any case. However,
at the end of the day, we really don't have to support random
out-of-tree interfaces.

> This patchset
> 1. reverts the syststamp code in the one driver (octeon)
> 2. reverts an unnecessary zero initialization in another (vxge)
> 3. modifies PF_PACKET to use syststamp is != 0 (because always == 0)
> 4. modifies SCM_TIMESTAMPING in the same way

Thanks for doing this series.

Acked-by: Richard Cochran <richardcochran@gmail.com>
