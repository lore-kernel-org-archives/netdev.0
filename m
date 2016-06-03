From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 11/17] net: dsa: Refactor selection of tag ops
 into a function
Date: Fri, 3 Jun 2016 10:19:14 -0700
Message-ID: <5751BC12.1090704@gmail.com>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
 <1464972256-10408-12-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35115 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbcFCRTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 13:19:17 -0400
Received: by mail-pf0-f196.google.com with SMTP id f144so12040786pfa.2
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 10:19:17 -0700 (PDT)
In-Reply-To: <1464972256-10408-12-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2016 09:44 AM, Andrew Lunn wrote:
> Replace the two switch statements with an array lookup, and store the
> result in the dsa tree structure. The drivers no longer need to know
> the selected tag protocol, so remove it from the dsa switch structure.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
