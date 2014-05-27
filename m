From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC PATCH] Add bridge ifindex to bridge fdb notify msgs
Date: Tue, 27 May 2014 17:51:12 -0400
Message-ID: <538508D0.5050405@mojatatu.com>
References: <1401165586-13836-1-git-send-email-roopa@cumulusnetworks.com> <20140527093713.512824b0@nehalam.linuxnetplumber.net> <5384C5C6.2090606@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:65180 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbaE0VvO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 17:51:14 -0400
Received: by mail-ie0-f174.google.com with SMTP id lx4so9509983iec.19
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 14:51:13 -0700 (PDT)
In-Reply-To: <5384C5C6.2090606@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/14 13:05, Roopa Prabhu wrote:

>> I like the idea of this, but the new attribute needs to be part of the
>> set
>> as well as notify and display infrastructure.
>>
> ok thanks, i will resubmit with set and other changes.

I think it is useful for symettry purposes to have both directions
have NDA_MASTER; but other than that, I dont see any purpose NDA_MASTER
serves. A bridge port is specified on the ndm msg to the kernel.
A bridge port can only belong to one master.
The kernel can deduce that already.
Infact i think specifying the NDA_MASTER may cause problems when
the specified NDA_MASTER is not the bridge to which the bridge port
belongs to....

cheers,
jamal
