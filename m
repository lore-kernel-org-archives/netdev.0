From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] lwtunnel: fix memory leak
Date: Tue, 18 Aug 2015 11:17:47 -0700
Message-ID: <55D376CB.1040905@cumulusnetworks.com>
References: <54251151b649756a3aa6f30c8fafe2357150f5ee.1439916029.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33169 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701AbbHRSRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 14:17:50 -0400
Received: by pabyb7 with SMTP id yb7so137955649pab.0
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 11:17:49 -0700 (PDT)
In-Reply-To: <54251151b649756a3aa6f30c8fafe2357150f5ee.1439916029.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/15, 9:41 AM, Jiri Benc wrote:
> The built lwtunnel_state struct has to be freed after comparison.
>
> Fixes: 571e722676fe3 ("ipv4: support for fib route lwtunnel encap attributes")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

looks like this was introduced in my last version when i decided to drop 
the get/put of lwtstate here. Thanks!
