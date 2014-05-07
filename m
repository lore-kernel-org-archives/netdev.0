From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] net: systemport: only update UMAC_CMD if
 something changed
Date: Wed, 7 May 2014 14:38:01 -0700
Message-ID: <CAGVrzcY14pLoEUC8MPne8LBnQ3WUOyxJf6LLQ=AwpBJNJsx3+A@mail.gmail.com>
References: <1399317652-20078-1-git-send-email-f.fainelli@gmail.com>
 <1399317652-20078-2-git-send-email-f.fainelli@gmail.com> <20140507.155957.393285971385097449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:34718 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751559AbaEGVim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 17:38:42 -0400
Received: by mail-qg0-f54.google.com with SMTP id q108so1765110qgd.41
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 14:38:41 -0700 (PDT)
In-Reply-To: <20140507.155957.393285971385097449.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-07 12:59 GMT-07:00 David Miller <davem@davemloft.net>:
> From: Florian Fainelli <f.fainelli@gmail.com>
> Date: Mon,  5 May 2014 12:20:51 -0700
>
>> +             reg &= ~((CMD_SPEED_MASK << CMD_SPEED_SHIFT) |
>> +                             CMD_HD_EN | CMD_RX_PAUSE_IGNORE |
>> +                             CMD_TX_PAUSE_IGNORE);
>
> While you're here use indentation more consistent with the rest of the
> networking for this kind of expression.
>
> On the second and third line, indent to the first column after the openning
> parenthesis on the first line.

My email client does not render this properly apparently, so I do see
the same problem as you hinted, but the lines do really follow your
recommendation if you take a look at the raw patch in e.g: patchwork.
-- 
Florian
