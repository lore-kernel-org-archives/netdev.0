From: Ben Greear <greearb@candelatech.com>
Subject: Re: keeping ifindex in 16bits or does it have to be sparse?
Date: Tue, 31 Mar 2009 08:24:50 -0700
Message-ID: <49D235C2.3050208@candelatech.com>
References: <1238512097.22664.190.camel@ragnarok>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeremy Jackson <jerj@coplanar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53589 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762684AbZCaPZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 11:25:00 -0400
In-Reply-To: <1238512097.22664.190.camel@ragnarok>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeremy Jackson wrote:
> The question came up when profiling Quagga... a performance issue occurs
> because it's iterating over a linked list of interface structures... and
> this person is using 2000 interfaces for ADSL PPPoE server.  It's an
> interesting use case.
>
> There are 2 options to make the interface lookup in quagga scale: array
> or hash.  My first thought was array, but it seems that ifindex can get
> sparse, that is, the largest ifindex can be much bigger (eg 408589) the
> number of max number of interfaces.
>
> So question to netdev, is it possible to reuse ifindex eventually, so it
> won't keep growing with interface add/delete, and are there
> (unnecessary) large jumps in the allocation sequence?
>   
Please use a hash...I'm sure someone will have a use-case with more than 
64k interfaces
sometime soon.

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


