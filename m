From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] net: l3mdev: Add master device lookup by
 index
Date: Sun, 22 Nov 2015 21:02:04 -0700
Message-ID: <56528FBC.6040205@cumulusnetworks.com>
References: <1447965121-2345-1-git-send-email-dsa@cumulusnetworks.com>
 <20151122.122359.2247708943529789130.davem@davemloft.net>
 <5651FBB8.6030008@cumulusnetworks.com>
 <20151122.131715.1858345389016284808.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36727 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753088AbbKWECP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 23:02:15 -0500
Received: by pacdm15 with SMTP id dm15so177988422pac.3
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2015 20:02:15 -0800 (PST)
In-Reply-To: <20151122.131715.1858345389016284808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/22/15 11:17 AM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Sun, 22 Nov 2015 10:30:32 -0700
>
>> In this case ...
>
> I understand the problem you are trying to solve, but I am saying
> you can't use sk_bound_dev_if to use it.
>

I am confused by that response given that sk_bound_dev_if is one of the 
key principals for the VRF implementation. Applications wanting to 
communicate over interfaces in a VRF have to set sk_bound_dev_if. If 
sk_bound_dev_if is not set by the kernel when the child socket is 
created the TCP handshake will not complete. It is not something that 
can be deferred until after accept.
