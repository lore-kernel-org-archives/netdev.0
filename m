From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] smsc911x: add fifo byteswap support V2
Date: Tue, 28 Apr 2009 09:21:42 +0100
Message-ID: <OFD0C1C563.A8F423C4-ON802575A6.002DDD59-802575A6.002DEC95@smsc.com>
References: <20090428073216.16015.15940.sendpatchset@rx1.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, Ian.Saturley@smsc.com, iwamatsu@nigauri.org,
	lethal@linux-sh.org, Magnus Damm <magnus.damm@gmail.com>,
	netdev@vger.kernel.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2614 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753531AbZD1IWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2009 04:22:01 -0400
In-Reply-To: <20090428073216.16015.15940.sendpatchset@rx1.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Magnus Damm <magnus.damm@gmail.com> wrote on 28/04/2009 08:32:16:

> From: Magnus Damm <damm@igel.co.jp>
> 
> This is V2 of the smsc911x fifo byteswap patch.
> 
> The smsc911x hardware supports both big and little and endian
> hardware configurations, and the linux smsc911x driver currently
> detects word order.
> 
> For correct operation on big endian platforms lacking swapped
> byte lanes the following patch is needed. Only fifo data is
> swapped, register data does not require any swapping. 
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>
> ---

Acked-by: Steve Glendinning <steve.glendinning@smsc.com>
