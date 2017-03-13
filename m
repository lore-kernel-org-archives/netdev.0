From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH] mpls: Do not decrement alive counter for unregister
 events
Date: Mon, 13 Mar 2017 16:38:55 -0600
Message-ID: <6f5259e4-5088-2dbd-f6f9-761500c9763b@cumulusnetworks.com>
References: <1489183899-2397-1-git-send-email-dsa@cumulusnetworks.com>
 <342ff118-9d48-e974-98e0-0789f6efb4f3@brocade.com>
 <cd885b2c-15f3-6f72-6fa9-aaabaea58ccd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com
To: Robert Shearman <rshearma@brocade.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35633 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754568AbdCMWi6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 18:38:58 -0400
Received: by mail-pg0-f51.google.com with SMTP id b129so71768700pgc.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 15:38:57 -0700 (PDT)
In-Reply-To: <cd885b2c-15f3-6f72-6fa9-aaabaea58ccd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/13/17 3:11 PM, David Ahern wrote:
> On 3/13/17 5:10 AM, Robert Shearman wrote:
>> Doesn't this leave the problem that if the device's link goes down and
>> then the device gets deleted the alive count will be decremented twice
>> for the same path?
> yes. and it exposes another bug in multipath selection.
> 

nevermind. I did not set the sysctl to keep ipv6 addresses; link down on
the veth device took out the address and route
