From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next v2 3/5] cxgb4: add parser to translate u32
 filters to internal spec
Date: Thu, 15 Sep 2016 07:27:24 -0700
Message-ID: <57DAAFCC.8000207@gmail.com>
References: <cover.1473759872.git.rahul.lakkireddy@chelsio.com>
 <ccd36e66281e2302cb46c7351be22a3ca276c07e.1473759872.git.rahul.lakkireddy@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com
To: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32882 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936284AbcIOO1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 10:27:37 -0400
Received: by mail-pa0-f49.google.com with SMTP id cm16so16505695pac.0
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 07:27:37 -0700 (PDT)
In-Reply-To: <ccd36e66281e2302cb46c7351be22a3ca276c07e.1473759872.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-13 04:42 AM, Rahul Lakkireddy wrote:
> Parse information sent by u32 into internal filter specification.
> Add support for parsing several fields in IPv4, IPv6, TCP, and UDP.
> 
> Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---

Looks good to me. Also curious if you would find it worthwhile to
have a cls_u32 mode that starts at L2 instead of the IP header? The
use case would be to use cls_u32 with various encapsulation protocols
in front of the IP header.

Reviewed-by: John Fastabend <john.r.fastabend@intel.com>
