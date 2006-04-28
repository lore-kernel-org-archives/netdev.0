From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 15:00:56 -0700 (PDT)
Message-ID: <20060428.150056.18940876.davem@davemloft.net>
References: <20060428.121636.54294183.davem@davemloft.net>
	<20060428124915.686911c1@localhost.localdomain>
	<20060428195930.GB21294@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, caitlinb@broadcom.com, kelly@au1.ibm.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:13260
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751679AbWD1WA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 18:00:59 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060428195930.GB21294@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 28 Apr 2006 23:59:30 +0400

> kevent can be used as poll without any changes to the socket code.
> There are two types of network related kevents - socket events
> (recv/send/accept) and network aio, which can be turned completely off
> in config.
> There are following events which are supported by kevent:
> o usual poll/select notifications
> o inode notifications (create/remove)
> o timer notifications
> o socket notifications (send/recv/accept)
> o network aio system
> o fs aio (project closed, aio_sendfile() is being developed instead)
> 
> Any of the above can be turned off by config option.

Feel free to post the current version of your kevent patch
here so we can discuss something concrete.

Maybe you have even some toy example user applications that
use kevent that people can look at too?  That might help
in understanding how it's supposed to be used.
