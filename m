From: Vikram Narayanan <vikram186@gmail.com>
Subject: Re: i.Mx6Quad - eth0: tx queue full!
Date: Thu, 21 Feb 2013 22:50:31 +0530
Message-ID: <5126575F.5080400@gmail.com>
References: <5106B7EE.3040603@gmail.com> <5106D5D4.2090200@boundarydevices.com> <5107FA00.2010809@gmail.com> <51081910.4030707@boundarydevices.com> <51093882.2060700@gmail.com> <51098AE4.5030305@boundarydevices.com> <CAHrpEqQc8QGV0UNgY_+-JVVQ8Tfq8gGfy6LfKFeaFNxf7hN7sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Troy Kisky <troy.kisky@boundarydevices.com>,
	netdev@vger.kernel.org, Fabio Estevam <festevam@gmail.com>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:55024 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816Ab3BURV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 12:21:29 -0500
Received: by mail-pa0-f49.google.com with SMTP id kp6so4814692pab.22
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 09:21:28 -0800 (PST)
In-Reply-To: <CAHrpEqQc8QGV0UNgY_+-JVVQ8Tfq8gGfy6LfKFeaFNxf7hN7sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/18/2013 12:59 PM, Frank Li wrote:
> Do you have a way to duplicate this issue consistently?

I think you meant "reproduce".

Yes. Almost everytime in my hardware.
Any network load would trigger this.

On the NFS, I did something like
for i in {1..10000};do;ls -lR *;done

and did a flood ping to the target as well.

Hope this helps,
Vikram
