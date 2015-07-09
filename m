From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v4 0/3] net: dsa: mv88e6xxx: add support for VLAN Table
 Unit
Date: Thu, 9 Jul 2015 17:03:24 -0400 (EDT)
Message-ID: <1231604948.157146.1436475804451.JavaMail.zimbra@savoirfairelinux.com>
References: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150708143805.GA32208@lunn.ch> <894793886.88178.1436375596747.JavaMail.zimbra@savoirfairelinux.com> <20150709.110135.225522890258902682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, netdev <netdev@vger.kernel.org>, sfeldma@gmail.com,
	jiri@resnulli.us, Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: David <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:62156 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379AbbGIVD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 17:03:29 -0400
In-Reply-To: <20150709.110135.225522890258902682.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

----- On Jul 9, 2015, at 2:01 PM, David davem@davemloft.net wrote:

> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Wed, 8 Jul 2015 13:13:16 -0400 (EDT)
> 
>> You're right. There's a single operation to clear the STU and VTU. I
>> will send a follow-up patch to send this command during the switch
>> setup.
> 
> Fix known bugs in the patch series, within the patch series, since it
> hasn't been merged yet.
> 
> Don't say "I'll fix this bug later", because we can fix it now.
> 
> Also as others have noted, this patch set creates an intermediate
> state where functionality is effectively broken.  So it is illogical
> to knowingly merge this patch series as-is.  You'll have to piece
> together all of the changes necessary such that the series is fully
> bisectable, which means at every patch along the way things function
> properly and do not break.

Dully noted.

Thank you,
-v
