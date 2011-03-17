From: Christian Hesse <mail@eworm.de>
Subject: Re: sky2, vlan and nat/masquerading
Date: Thu, 17 Mar 2011 22:40:44 +0100
Message-ID: <20110317224044.3ff4fbd8@leda.vpn.lugor.de>
References: <20110309181522.61ca1cc7@leda.vpn.lugor.de>
	<AANLkTi=AJJA0d0=CFuS66=+O6b80Ejj0w3NfKQ+OWzsK@mail.gmail.com>
	<20110314111105.5a62e092@leda.vpn.lugor.de>
	<AANLkTikXBz6ZpuSgqaAV-=Jr3qtDQ3T_We42R65Sd20O@mail.gmail.com>
	<20110315085326.1a1019aa@leda.vpn.lugor.de>
	<AANLkTikeVWuDMhws4JX0S+WhKFja8zU_2ZY3KZZUAXks@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([80.190.48.209]:52295 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932090Ab1CQVku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 17:40:50 -0400
In-Reply-To: <AANLkTikeVWuDMhws4JX0S+WhKFja8zU_2ZY3KZZUAXks@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Mar 2011 12:23:48 -0700 Jesse Gross <jesse@nicira.com> wrote:
> Hmm, it's pretty interesting that the extra vlan tag magically
> appears.  I'll have to reproduce it to investigate further, as the
> source isn't readily obvious to me.  You said that if you swap out a
> different NIC but keep everything else the same the problem goes away?
>  That also is strange because the packet capture should take place
> before the driver.

Correctly. I tested with asix and mcs7830.

> Can you try using ethtool to turn off txvlan and see if that makes a
> difference?

Sure. I will give it a try tomorrow.
-- 
Schoene Gruesse
Chris
