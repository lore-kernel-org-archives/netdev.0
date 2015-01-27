From: David Ahern <dsahern@gmail.com>
Subject: Re: Does arping update arp table?
Date: Tue, 27 Jan 2015 13:46:40 -0700
Message-ID: <54C7F930.6090506@gmail.com>
References: <54C7E5B5.8060401@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: Murali Karicheri <m-karicheri2@ti.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:32836 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932569AbbA0Uqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 15:46:51 -0500
Received: by mail-pa0-f45.google.com with SMTP id et14so20749044pad.4
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 12:46:51 -0800 (PST)
In-Reply-To: <54C7E5B5.8060401@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/27/15 12:23 PM, Murali Karicheri wrote:
> However this command doesn't update the arp table on my Keystone EVM
> based on v3.19.x and also newer ubuntu machine based on v3.11. Is this
> expected behavior? I believe the arp response resulting from a arping
> command is controlled through per interface accept sys control like as
> in gratuitous arp. Please repond.

echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_accept
