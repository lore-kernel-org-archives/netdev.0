From: Ben Greear <greearb@candelatech.com>
Subject: Re: rtl8150 usb driver, needs more vendor ids?
Date: Tue, 20 Jun 2006 07:25:02 -0700
Message-ID: <4498053E.8000406@candelatech.com>
References: <449799BA.1050303@candelatech.com> <Pine.LNX.4.64.0606201308130.6281@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, petkan@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:33477 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751053AbWFTOZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 10:25:13 -0400
To: Petko Manolov <petkan@nucleusys.com>
In-Reply-To: <Pine.LNX.4.64.0606201308130.6281@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Petko Manolov wrote:
>     Hi Ben,
> 
> What you have sent me is a bit of a puzzle.
> 
> Looking at the device's details i can see it is not RTL8150 based 
> device, but ADMtek's ADM8511.  Both vendor and device IDs have been 
> listed in pegasus.c for a long long time.
> 
> Using rtl8150.c will not help at all since it talks to a different 
> device. I suggest using pegasus.c ...

Ahhh, that would explain it.  The pegasus driver loads straight
away.

Thanks!
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

