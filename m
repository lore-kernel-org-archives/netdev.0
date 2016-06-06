From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 0/2] net: vrf: Improve use of FIB rules
Date: Mon, 6 Jun 2016 17:47:52 -0600
Message-ID: <990a6fac-f38b-766f-cbdd-a9025604bb8f@cumulusnetworks.com>
References: <1464982616-23030-1-git-send-email-dsa@cumulusnetworks.com>
 <20160606.154738.2069568651897544011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33843 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbcFFXrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 19:47:49 -0400
Received: by mail-pa0-f52.google.com with SMTP id bz2so39825596pad.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 16:47:49 -0700 (PDT)
In-Reply-To: <20160606.154738.2069568651897544011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/6/16 4:47 PM, David Miller wrote:
>
> I hate module parameters.
>
> And you don't even need one in this situation, just use a default preference
> of 1000 and add a newlink netlink attribute that can change it.

The intent is to generate default rules similar to what is done for 
local and main tables. Users are free to delete and move rules if they 
don't like the defaults. I'll drop the module parameter and just do the 
rule add once on first device create. From there user intentions reign 
if they move it.
