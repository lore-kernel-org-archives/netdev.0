From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Disable tcp MSS option in three way handshake?
Date: Thu, 25 Oct 2012 15:50:57 -0700
Message-ID: <5089C251.4090108@hp.com>
References: <CAK3+h2xKHBNXzY0WNwPV+oGbY00UVfJpO-qjFW2cxCpmdt+hAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Vincent Li <vincent.mc.li@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:22756 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532Ab2JYWu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 18:50:58 -0400
In-Reply-To: <CAK3+h2xKHBNXzY0WNwPV+oGbY00UVfJpO-qjFW2cxCpmdt+hAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2012 03:27 PM, Vincent Li wrote:
> Hi,
>
> this sounds crazy, we have a weird situation that an unknown tcp
> implementation not putting tcp MSS option in the SYN/ACK which caused
> us some issue.

All that means is you/your TCP stack are to assume an MSS of 536 bytes. 
  In that sense at least, there is nothing (supposed to be) weird about it.

rick jones
