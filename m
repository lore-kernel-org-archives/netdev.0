From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 12:16:36 -0700 (PDT)
Message-ID: <20060428.121636.54294183.davem@davemloft.net>
References: <20060428172932.GB16916@2ka.mipt.ru>
	<20060428104118.6a056a59@localhost.localdomain>
	<20060428175538.GA13898@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14742
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751056AbWD1TS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 15:18:27 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060428175538.GA13898@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 28 Apr 2006 21:55:39 +0400

> On Fri, Apr 28, 2006 at 10:41:18AM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
> > Second, introducing
> > kevents, seems unnecessary and hasn't been accepted in the mainline.
> 
> kevent was never sent to lkml@ although it showed over 40% win over epoll for
> test web server. Sending it to lkml@ is just jumping into ... not into
> technical world, so I posted it first here, but without much attention
> though.

Frankly I found kevents to be a very strong idea.
