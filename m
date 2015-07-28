From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4] af_mpls: fix undefined reference to ip6_route_output
Date: Tue, 28 Jul 2015 12:28:58 -0700
Message-ID: <55B7D7FA.8070301@cumulusnetworks.com>
References: <1438065624-38229-1-git-send-email-roopa@cumulusnetworks.com> <1438088676.25794.19.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, tgraf@suug.ch, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33758 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbbG1T3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 15:29:00 -0400
Received: by padck2 with SMTP id ck2so74430033pad.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 12:29:00 -0700 (PDT)
In-Reply-To: <1438088676.25794.19.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/28/15, 6:04 AM, Hannes Frederic Sowa wrote:
> Can't you simply use ipv6_stub_impl.ipv6_dst_lookup with sk=NULL to do
> that and don't have a run-time dependency on IPv6 at all (for the cost
> of a function pointer).
  ipv6_stub_impl.ipv6_dst_lookup seems to require sk today.
But it only needs it to get 'net' in the beginning and sk is optional 
afterwards.
I will submit a patch to add 'net' as an arg  to ipv6_dst_lookup.
Users of ipv6_dst_lookup are few and that seems like an easy change and 
helps my patch.
If you or others think otherwise, pls let me know.
