From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 10/24] mdio: Move allocation of interrupts
 into core
Date: Mon, 04 Jan 2016 12:17:57 -0800
Message-ID: <568AD375.90809@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-11-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36562 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbcADUS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:18:29 -0500
Received: by mail-pa0-f67.google.com with SMTP id a20so10501746pag.3
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 12:18:28 -0800 (PST)
In-Reply-To: <1451929022-5580-11-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Have mdio_alloc() create the array of interrupt numbers, and
> initialize it to POLLING. This is what most MDIO drivers want, so
> allowing code to be removed from the drivers.

Yeah, this should have been done a long time ago, thanks!

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
