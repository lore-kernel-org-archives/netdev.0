From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 1/5] netlink: extended ACK reporting
Date: Tue, 11 Apr 2017 12:57:59 -0600
Message-ID: <cb6106f2-3128-da79-69bf-a10b249db054@cumulusnetworks.com>
References: <1491894172.31620.2.camel@sipsolutions.net>
 <9a68aa01-474c-7054-30c2-473ee1250abe@cumulusnetworks.com>
 <20170411173143.GA1899@salvia>
 <20170411.134225.398046538225438175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, jhs@mojatatu.com, jbenc@redhat.com,
        jiri@resnulli.us
To: David Miller <davem@davemloft.net>, pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:35231 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752151AbdDKS6B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 14:58:01 -0400
Received: by mail-pg0-f46.google.com with SMTP id 81so2788046pgh.2
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 11:58:01 -0700 (PDT)
In-Reply-To: <20170411.134225.398046538225438175.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/11/17 11:42 AM, David Miller wrote:
> David, if you have a specific case where it's absolutely impossible
> to resolve this when the library is converted to support extended
> ACKs, please mention it.

I don't have a specific library in mind. It is more the disjoint nature
of a socket option and message parsing, and thinking through the API.
