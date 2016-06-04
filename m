From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Implement FDB operations
Date: Fri, 3 Jun 2016 17:06:46 -0700
Message-ID: <57521B96.3050604@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34282 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbcFDAGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:06:48 -0400
Received: by mail-pf0-f174.google.com with SMTP id 62so48275017pfd.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 17:06:47 -0700 (PDT)
In-Reply-To: <1464998733-10405-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 05:05 PM, Florian Fainelli wrote:
> Add support for the FDB add, delete, and dump operations. The add and
> delete operations are implemented using directed ARL operations using
> the specified MAC address and consist in a read operation, write and
> readback operation.
> 
> The dump operation consists in using the ARL search and software
> filtering entries which are not for the desired port.

And this one too should be discarded.
-- 
Florian
