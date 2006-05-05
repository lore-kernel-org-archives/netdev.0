From: Daniel Drake <dsd@gentoo.org>
Subject: Re: sky2 1.3-rc1
Date: Fri, 05 May 2006 19:42:27 +0100
Message-ID: <445B9C93.4070406@gentoo.org>
References: <1146667951.3056.25.camel@fc5test.deadmoose.com>	<20060503120507.4558c675@localhost.localdomain>	<445B626B.1070407@gentoo.org>	<20060505173509.GK2757@cip.informatik.uni-erlangen.de> <20060505104536.2baefa5e@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>,
	Bill Hoover <bill@luminescent.com>,
	Bertrand Jacquin <beber@gna.org>, micheleschi@libero.it,
	netdev@vger.kernel.org, teppic74@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta09-winn.ispmail.ntl.com ([81.103.221.49]:58229 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751204AbWEES03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 May 2006 14:26:29 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060505104536.2baefa5e@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> What is happening is that if there is a misconfiguration and irq routing
> is messed up (ie edge trigged). The driver will degenerate to polling every 100ms.
> If your system is this misconfigured, then ACPI or the BIOS needs to be fixed
> and the driver really only needs to work well enough to get the bug report out ;-)

Ok, thanks for the explanation.

Can you give any hints as to how we can classify this misconfiguration? 
Barry's system has a level triggered IRQ assigned to sky2, and that IRQ 
is not shared:

http://bugs.gentoo.org/show_bug.cgi?id=132056#c3

I'm just looking for something I can take to the ACPI developers, other 
than "its broken because Stephen said so" ;)

Thanks.
Daniel
