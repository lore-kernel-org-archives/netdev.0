From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip monitor: Fixed printing timestamp few times
Date: Wed, 3 Dec 2014 09:13:38 -0800
Message-ID: <20141203091338.2d32de2c@urahara>
References: <1417389262-25189-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:46956 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaLCRNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:13:49 -0500
Received: by mail-pd0-f178.google.com with SMTP id g10so15928267pdj.9
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:13:49 -0800 (PST)
In-Reply-To: <1417389262-25189-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  1 Dec 2014 01:14:22 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> Another fix when timestamp is printed few times
> before the event message.
> 
> Fixed by skipping the message types which are not supported.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

I don't see how you could get into accept_msg and cause this.

The filtering should already be done by kernel for most things.
The code already filters TC messages in kernel. Other types
should be done as well.

Ps: this code is crying to be a switch statement.
