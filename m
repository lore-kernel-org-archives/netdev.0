From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Tue, 27 Jan 2015 07:55:18 -0700
Message-ID: <54C7A6D6.8020805@gmail.com>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com>	 <20150122224033.6e2db5ce@urahara>	 <1422015737.2824.8.camel@stressinduktion.org>	 <20150127045653.GB13164@gospo.home.greyhouse.net> <1422351861.13969.5.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:45717 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754360AbbA0OzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 09:55:21 -0500
Received: by mail-pd0-f179.google.com with SMTP id v10so19263969pde.10
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 06:55:20 -0800 (PST)
In-Reply-To: <1422351861.13969.5.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/27/15 2:44 AM, Hannes Frederic Sowa wrote:
>> You are probably correct that many will not switch, but this sysctl
>> gives those who want to switch a nice option without having to carry
>> extra kernel patches.  I like it.
>
> I don't see any problem with the patch in general but DAD should
> definitely happen on reenabling interfaces. Current behavior does not
> seem fine to me. It's ok if this patch doesn't change this behavior now
> but a follow-up one will be needed then.
>
> David, will you look after the DAD logic and do you plan a follow-up
> patch?

Yes, I do plan a follow-up patch for this change. Will work on that this 
week.

 From the discussion a second patch is needed to make sure DAD is done 
on a link up if there is an address configured.

David
