From: Phil Karn <karn@ka9q.net>
Subject: Re: Off-by-one error in net/8021q/vlan.c
Date: Wed, 16 Feb 2011 07:58:09 -0800
Message-ID: <4D5BF411.4020204@ka9q.net>
References: <4D5BADCF.5000804@ka9q.net> <AANLkTinBOk8ZNQvRpMqZQE_vOu63QVzDZ4ceRRUDvJD_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:61337 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795Ab1BPP6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 10:58:14 -0500
Received: by pva4 with SMTP id 4so215142pva.19
        for <netdev@vger.kernel.org>; Wed, 16 Feb 2011 07:58:14 -0800 (PST)
In-Reply-To: <AANLkTinBOk8ZNQvRpMqZQE_vOu63QVzDZ4ceRRUDvJD_@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/11 4:51 AM, richard -rw- weinberger wrote:
> On Wed, Feb 16, 2011 at 11:58 AM, Phil Karn <karn@ka9q.net> wrote:
>> The range check on vlan_id in register_vlan_device is off by one, and it
>> prevents the creation of a vlan interface for vlan ID 4095. (OSX allows
>> this, I checked.)
> 
> Then OSX should fix their code. 4095 is reserved.
> 

If it's reserved, then it's up to the user to reserve it.

I actually had reason to use this to fix a misconfigured host that was
using vlan 4095. This got in my way.
