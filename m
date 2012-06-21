From: <Menny_Hamburger@Dell.com>
Subject: IPV6 ndisc::  Bad NIC causing  IPV6 NDP to stop working
Date: Thu, 21 Jun 2012 08:59:46 +0100
Message-ID: <D8C50530D6022F40A817A35C40CC06A70B34DBEFCF@DUBX7MCDUB01.EMEA.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:54167 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753608Ab2FUIJy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 04:09:54 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Our machines runs EL5.8 x86_64.
We have witnessed several cases where we suspect that a bad NIC on the machine caused IPV6 neighbour discovery to stop working on all the other NICs - when this happens ping6 fails on every NIC we try it.
>From looking into the code I see that there is only a single socket assigned for NDP; Does it sound logical to allocate a socket per interface instead of a single global socket.
I have found the following thread in LKML: https://lkml.org/lkml/2006/11/29/335, and it seems that this allocation issue still exists in EL5 based kernels - could this cause the above problem?

Thanks,
Menny
