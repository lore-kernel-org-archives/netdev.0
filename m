From: richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: Off-by-one error in net/8021q/vlan.c
Date: Wed, 16 Feb 2011 17:10:59 +0100
Message-ID: <AANLkTikNrwd31RBj1gc6kSaT=qodS=A=YntM=72PMbDf@mail.gmail.com>
References: <4D5BADCF.5000804@ka9q.net>
	<AANLkTinBOk8ZNQvRpMqZQE_vOu63QVzDZ4ceRRUDvJD_@mail.gmail.com>
	<4D5BF411.4020204@ka9q.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kaber@trash.net, netdev@vger.kernel.org
To: Phil Karn <karn@ka9q.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48835 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab1BPQLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 11:11:00 -0500
Received: by eye27 with SMTP id 27so864954eye.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 08:10:59 -0800 (PST)
In-Reply-To: <4D5BF411.4020204@ka9q.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 16, 2011 at 4:58 PM, Phil Karn <karn@ka9q.net> wrote:
> On 2/16/11 4:51 AM, richard -rw- weinberger wrote:
>> On Wed, Feb 16, 2011 at 11:58 AM, Phil Karn <karn@ka9q.net> wrote:
>>> The range check on vlan_id in register_vlan_device is off by one, and it
>>> prevents the creation of a vlan interface for vlan ID 4095. (OSX allows
>>> this, I checked.)
>>
>> Then OSX should fix their code. 4095 is reserved.
>>
>
> If it's reserved, then it's up to the user to reserve it.

No.

See:
http://standards.ieee.org/getieee802/download/802.1Q-2005.pdf

-- 
Thanks,
//richard
