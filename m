From: Patrick McHardy <kaber@trash.net>
Subject: Re: vlan: update vlan carrier state for admin up/down
Date: Tue, 05 May 2009 14:41:08 +0200
Message-ID: <4A0033E4.2070802@trash.net>
References: <30658.1240619463@death.nxdomain.ibm.com>	<49F4BCEB.6040507@candelatech.com>	<13072.1240876558@death.nxdomain.ibm.com> <20090427.183640.182469000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, greearb@candelatech.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40501 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183AbZEEMlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 08:41:10 -0400
In-Reply-To: <20090427.183640.182469000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Mon, 27 Apr 2009 16:55:58 -0700
> 
>> I'm reluctant to mess with this behavior without knowing why it
>> works this way; there may be a good reason for it that I'm not aware
>> of.
> 
> To be honest I think it's just that this is one huge dark
> corner of behavior for many virtual devices, rather than
> any of it being intentional.

Indeed. In case of VLANs it has always been this way and I'm
reluctant to change the default behaviour since people might
be relying on this to flush their routes or something similar.

For new drivers I'd say they should always use operstate. For
VLAN the safest way would be to add a flag to disable this
behaviour.
