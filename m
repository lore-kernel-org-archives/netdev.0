From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC net-next 0/3] Proposal for VRF-lite
Date: Mon, 08 Jun 2015 13:13:40 -0600
Message-ID: <5575E964.7060308@gmail.com>
References: <cover.1433561681.git.shm@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	hannes@stressinduktion.org, nicolas.dichtel@6wind.com,
	ebiederm@xmission.com, hadi@mojatatu.com, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37028 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbbFHTNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 15:13:45 -0400
Received: by igbsb11 with SMTP id sb11so64492278igb.0
        for <netdev@vger.kernel.org>; Mon, 08 Jun 2015 12:13:44 -0700 (PDT)
In-Reply-To: <cover.1433561681.git.shm@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/15 12:35 PM, Shrijeet Mukherjee wrote:
> 5. Debugging is built-in as tcpdump and counters on the VRF device
>     works as is.

Is the intent that something like this

   tcpdump -i vrf0

can be used to see vrf traffic?

vrf_handle_frame only bumps counters; it does not switch skb->dev to the 
vrf device so for Rx path tcpdump will not get the packets. ie., tcpdump 
only shows outbound packets.
