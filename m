From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Support ip route get via given table
Date: Thu, 3 Sep 2015 17:25:59 -0600
Message-ID: <55E8D707.7010309@cumulusnetworks.com>
References: <1441220592-7339-1-git-send-email-dsa@cumulusnetworks.com>
 <20150903.154015.1172003362734952780.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35574 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754974AbbICX0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 19:26:02 -0400
Received: by ioiz6 with SMTP id z6so5566454ioi.2
        for <netdev@vger.kernel.org>; Thu, 03 Sep 2015 16:26:01 -0700 (PDT)
In-Reply-To: <20150903.154015.1172003362734952780.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/3/15 4:40 PM, David Miller wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> Date: Wed,  2 Sep 2015 12:03:12 -0700
>
>> Add support for 'ip [-6] route get table X' where the user wants to
>> force the FIB lookup from a given table.
>>
>> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
>
> As Thomas mentioned, this adds cost to the FIB lookup fastpath
> for a control-plane only feature, which is really undesirable.
>
> I think I'll pass on this change for now, sorry.
>

Got it. I had other ideas on how to implement it. Figured I would start 
with the simplest.
