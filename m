From: David Miller <davem@davemloft.net>
Subject: Re: Compile Error for TI Davinci
Date: Fri, 20 Nov 2009 09:50:00 -0800 (PST)
Message-ID: <20091120.095000.265125164.davem@davemloft.net>
References: <FCCFB4CDC6E5564B9182F639FC35608702FA751A01@dbde02.ent.ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, chaithrika@ti.com
To: srk@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44197
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753396AbZKTRtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 12:49:42 -0500
In-Reply-To: <FCCFB4CDC6E5564B9182F639FC35608702FA751A01@dbde02.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Govindarajan, Sriramakrishnan" <srk@ti.com>
Date: Fri, 20 Nov 2009 17:36:38 +0530

> Patch for "TI DaVinci EMAC: Clear statistics register properly"(commit- 0fe7463a35aadfaf22d1ca58325ab3851b8d757c on net-next) has dependency on 
> Patch "TI DaVinci EMAC: Minor macro related updates "(commit - 69ef9694099802f7feeb23182dfb869e7c5f76f0 on net-next).
> 
> The first patch has been pushed upstream while the later still remains on
> Net-next. Due to the dependency between these two, we are seeing compilation 
> Failure when we build for Davinci.
> 
> Can you please push "TI DaVinci EMAC: Minor macro related updates" - 69ef9694099802f7feeb23182dfb869e7c5f76f0 up-stream .

This should not be happening, because yesterday I merged Linus's
tree into net-2.6 and afterwards I merged net-2.6 into net-next-2.6

Please verify that the problem still occurs.
