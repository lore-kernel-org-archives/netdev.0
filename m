From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [klibc] [patch] import socket defines
Date: Thu, 10 Jan 2008 23:02:37 -0800
Message-ID: <4787148D.3050408@zytor.com>
References: <477BD374.6060506@zytor.com>	<20080110.221615.188955433.davem@davemloft.net>	<200801110123.38406.vapier@gentoo.org> <20080110.224749.66236050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vapier@gentoo.org, netdev@vger.kernel.org, klibc@zytor.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:48468 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757247AbYAKHHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 02:07:23 -0500
In-Reply-To: <20080110.224749.66236050.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> 
> Hmmm...
> 
> Doesn't glibc include linux/socket.h?  If so, before it wouldn't get
> the sa_family_t et al. defines (because __GLIBC__ will be defined and
> it will be >= 2), but with your change it get those things.
> 
> Correct me if I'm wrong.
> 

At the moment, yes, it does.

	-hpa

