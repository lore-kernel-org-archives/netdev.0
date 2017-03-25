From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] IB/rxe: increment msn only when completing a request
Date: Fri, 24 Mar 2017 22:07:54 -0400
Message-ID: <1490407674.2404.37.camel@redhat.com>
References: <1487947106-21382-1-git-send-email-david.marchand@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: David Marchand <david.marchand@6wind.com>, monis@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60384 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936795AbdCYCH5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 22:07:57 -0400
In-Reply-To: <1487947106-21382-1-git-send-email-david.marchand@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-24 at 15:38 +0100, David Marchand wrote:
> According to C9-147, MSN should only be incremented when the last
> packet of
> a multi packet request has been received.
> 
> "Logically, the requester associates a sequential Send Sequence
> Number
> (SSN) with each WQE posted to the send queue. The SSN bears a one-
> to-one relationship to the MSN returned by the responder in each re-
> sponse packet. Therefore, when the requester receives a response, it
> in-
> terprets the MSN as representing the SSN of the most recent request
> completed by the responder to determine which send WQE(s) can be
> completed."
> 
> Fixes: 8700e3e7c485 ("Soft RoCE driver")
> 
> Signed-off-by: David Marchand <david.marchand@6wind.com>

Thanks, applied.

-- 
Doug Ledford <dledford@redhat.com>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD
