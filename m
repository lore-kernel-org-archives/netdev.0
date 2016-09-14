From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net v1] fib_rules: interface group matching
Date: Wed, 14 Sep 2016 09:25:49 -0600
Message-ID: <c4f00f4e-aad3-f3d4-3c7c-8fe39c8f1720@cumulusnetworks.com>
References: <20160914124025.13417-1-vincent@bernat.im>
 <9540c014-78c5-9f9c-16d7-75a564f6c018@cumulusnetworks.com>
 <87h99ipnhu.fsf@zoro.exoscale.ch>
 <e8df55df-c22f-19a3-fabc-5fb592433706@cumulusnetworks.com>
 <87a8fapl7l.fsf@zoro.exoscale.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Wilson Kok <wkok@cumulusnetworks.com>, netdev@vger.kernel.org
To: Vincent Bernat <vincent@bernat.im>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:35665 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760246AbcINPZx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 11:25:53 -0400
Received: by mail-it0-f42.google.com with SMTP id r192so49153852ita.0
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 08:25:52 -0700 (PDT)
In-Reply-To: <87a8fapl7l.fsf@zoro.exoscale.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/14/16 9:14 AM, Vincent Bernat wrote:
> I could just give more time to VRF. I also had some concerns over
> performance with the way Netfilter integration is done, but I understand
> that I could just stay away from POSTROUTING rules which is the only
> hook executed twice?
> 

With the changes that were committed this past weekend, the VRF code is now setup where I can set a flag on a per VRF basis to disable the extra rx and tx processing - ie., no network taps, no netfilter, no qdisc, etc. Drops the overhead of VRF to ~3% maybe a bit less. I need to think about the user api a bit more and formalize the patch. Given my other commitments that probably won't happen until mid-October. But in terms of a building block, the overhead of VRF is continuing to drop.
