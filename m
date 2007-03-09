From: Tejun Heo <htejun@gmail.com>
Subject: Re: 2.6.20-rc4-mm1: PCI=n: drivers/net/3c59x.c compile error
Date: Fri, 09 Mar 2007 21:54:10 +0900
Message-ID: <45F158F2.9040907@gmail.com>
References: <20070111222627.66bb75ab.akpm@osdl.org>	<20070124135354.GI17836@stusta.de>	<45B76946.1070009@ru.mvista.com>	<45D756D7.4060106@ru.mvista.com>	<45D75853.1060607@ru.mvista.com>	<45E2DF13.9010200@ru.mvista.com>	<20070226092644.aea76b37.randy.dunlap@oracle.com>	<20070226211401.GC3810@kroah.com>	<45ED9390.3000308@ru.mvista.com> <20070306084751.b82a7b84.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sshtylyov@ru.mvista.com>,
	Greg KH <greg@kroah.com>, linux-pci@atrey.karlin.mff.cuni.cz,
	Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.226]:6043 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767233AbXCIMyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 07:54:17 -0500
Received: by nz-out-0506.google.com with SMTP id s1so761193nze
        for <netdev@vger.kernel.org>; Fri, 09 Mar 2007 04:54:17 -0800 (PST)
In-Reply-To: <20070306084751.b82a7b84.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Randy Dunlap wrote:
>>     Erm, before I do that, could somebody explain what
>>
>> #define HAVE_PCI_REQ_REGIONS 2
>>
>> accompanying their declaration is for? I have't found any references to it in 
>> the source. Should I duplicate it for CONFIG_PCI=n case (I guess not)?
> 
> I wouldn't since it's not used anywhere, but maybe Tejun could comment
> on it...

This is the first time I see that macro.  There is no user in the whole
source.  I think the best way is to just kill it.

Thanks.

-- 
tejun
