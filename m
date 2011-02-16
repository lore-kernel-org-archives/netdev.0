From: Patrick McHardy <kaber@trash.net>
Subject: Re: Off-by-one error in net/8021q/vlan.c
Date: Wed, 16 Feb 2011 14:22:25 +0100
Message-ID: <4D5BCF91.1010309@trash.net>
References: <4D5BADCF.5000804@ka9q.net> <AANLkTinBOk8ZNQvRpMqZQE_vOu63QVzDZ4ceRRUDvJD_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Phil Karn <karn@ka9q.net>, netdev@vger.kernel.org
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33040 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754512Ab1BPNW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 08:22:26 -0500
In-Reply-To: <AANLkTinBOk8ZNQvRpMqZQE_vOu63QVzDZ4ceRRUDvJD_@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.02.2011 13:51, richard -rw- weinberger wrote:
> On Wed, Feb 16, 2011 at 11:58 AM, Phil Karn <karn@ka9q.net> wrote:
>> The range check on vlan_id in register_vlan_device is off by one, and it
>> prevents the creation of a vlan interface for vlan ID 4095. (OSX allows
>> this, I checked.)
> 
> Then OSX should fix their code. 4095 is reserved.

I agree.

