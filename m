From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPV6 ndisc::  Bad NIC causing  IPV6 NDP to stop working
Date: Thu, 21 Jun 2012 10:22:52 +0200
Message-ID: <1340266972.4604.4404.camel@edumazet-glaptop>
References: <D8C50530D6022F40A817A35C40CC06A70B34DBEFCF@DUBX7MCDUB01.EMEA.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Menny_Hamburger@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56665 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758535Ab2FUIW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 04:22:58 -0400
Received: by eeit10 with SMTP id t10so89819eei.19
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2012 01:22:57 -0700 (PDT)
In-Reply-To: <D8C50530D6022F40A817A35C40CC06A70B34DBEFCF@DUBX7MCDUB01.EMEA.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-21 at 08:59 +0100, Menny_Hamburger@Dell.com wrote:
> Hi,
> 
> Our machines runs EL5.8 x86_64.
> We have witnessed several cases where we suspect that a bad NIC on the machine caused IPV6 neighbour discovery to stop working on all the other NICs - when this happens ping6 fails on every NIC we try it.
> From looking into the code I see that there is only a single socket assigned for NDP; Does it sound logical to allocate a socket per interface instead of a single global socket.
> I have found the following thread in LKML: https://lkml.org/lkml/2006/11/29/335, and it seems that this allocation issue still exists in EL5 based kernels - could this cause the above problem?
> 

What is a bad NIC, and why not fixing it ?
