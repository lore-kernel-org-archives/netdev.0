From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ppp_generic - fix broken userspace
Date: Sat, 10 Jan 2009 23:35:03 -0800 (PST)
Message-ID: <20090110.233503.222465267.davem@davemloft.net>
References: <20090110202802.GF29349@localhost>
	<20090110203112.GG29349@localhost>
	<18793.15831.279207.252421@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, akpm@linux-foundation.org,
	jchapman@katalix.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59590
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751065AbZAKHfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 02:35:03 -0500
In-Reply-To: <18793.15831.279207.252421@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Mackerras <paulus@samba.org>
Date: Sun, 11 Jan 2009 11:31:19 +1100

> Judging by the subject, it sounds like I'm not going to like it...

PPP was converted to use IDR instead of PPP's duplicate
implementation.

A bug was introduced in that conversion, and that bug is being fixed
here.

What is not to like? :-)
