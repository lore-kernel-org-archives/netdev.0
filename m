From: <Menny_Hamburger@Dell.com>
Subject: [ndisc6] Bad NIC causing  IPV6 NDP to stop working
Date: Wed, 20 Jun 2012 18:09:39 +0100
Message-ID: <D8C50530D6022F40A817A35C40CC06A70B34C74BF3@DUBX7MCDUB01.EMEA.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:63171 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754434Ab2FTRTO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 13:19:14 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We have witnessed several cases where we suspect that a bad NIC on the machine caused neighbour discovery to stop working on all the other NICs - when this happens ping6 fails on every NIC we try it.
>From looking into the code I see that there is only a single socket assigned for NDP; Does it sound logical to allocate a socket per interface instead of a single global socket.

Thanks,
Menny
