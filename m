From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, post-2.6.36 regression fix] r8169: Fix runtime power
 management
Date: Fri, 10 Dec 2010 11:09:46 -0800 (PST)
Message-ID: <20101210.110946.260074147.davem@davemloft.net>
References: <201012090232.14375.rjw@sisk.pl>
	<20101209092804.GA4113@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, mjg@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org
To: romieu@fr.zoreil.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101209092804.GA4113@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 9 Dec 2010 10:28:04 +0100

> Rafael J. Wysocki <rjw@sisk.pl> :
> [...]
>> I noticed that one of the post-2.6.36 patches broke runtime PM of the
>> r8169 on my MSI Wind test machine in such a way that the link was not
>> brought up after reconnecting the network cable.
>> 
>> In the process of debugging the issue I realized that we only should
>> invoke the runtime PM functions in rtl8169_check_link_status() when
>> link change is reported and if we do so, the problem goes away.
>> Moreover, this allows rtl8169_runtime_idle() to be simplified quite
>> a bit.
>> 
>> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> 
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied, thanks.
