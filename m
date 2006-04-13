From: Dave Dillow <dave@thedillows.org>
Subject: Re: [RFD][PATCH] typhoon and core sample for folding away VLAN stuff
Date: Wed, 12 Apr 2006 21:24:00 -0400
Message-ID: <443DA830.8030209@thedillows.org>
References: <200604071628.30486.vda@ilport.com.ua> <200604111502.52302.vda@ilport.com.ua> <200604111517.37215.netdev@axxeo.de> <200604122132.46113.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Oeser <netdev@axxeo.de>, Denis Vlasenko <vda@ilport.com.ua>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:33679 "EHLO smtp.knology.net")
	by vger.kernel.org with ESMTP id S932417AbWDMBXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 21:23:52 -0400
To: Ingo Oeser <ioe-lkml@rameria.de>
In-Reply-To: <200604122132.46113.ioe-lkml@rameria.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> Dave Dillow: Is this style clean enough to have it in your driver?

Though I'm not real fond of Denis's last patch, I think I prefer it's 
style to this, solely because it removes more code when VLANs are 
disabled -- you've left the spin_locks in, and have more #ifdefs.

Regardless, I remain opposed to this particular instance of bloat 
busting. While both patches have improved in style, they remove a useful 
feature and make the code less clean, for no net gain.

> This kind of changes are important, because bloat creeps in byte by byte
> of unused features. So I really appreciate your work here Denis.

On SMP FC4, typhoon.ko has a text size of 68330, so you need to cut 2794 
bytes to see an actual difference in memory usage for a module. Non-SMP 
it is 67741, so there you only need to cut 2205 bytes to get a win.

Every byte counts, except when it doesn't.

