From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/8] Support unix domain sockets across namespaces
Date: Wed, 16 Jun 2010 15:15:36 -0700 (PDT)
Message-ID: <20100616.151536.70195214.davem@davemloft.net>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: serue@us.ibm.com, containers@lists.osdl.org,
	daniel.lezcano@free.fr, netdev@vger.kernel.org, xemul@parallels.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53024
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754548Ab0FPWPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 18:15:25 -0400
In-Reply-To: <m1hbl7hxo3.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 13 Jun 2010 06:25:32 -0700

> This patchset takes a addressing all of the issues that crop up with
> unix domain sockets when the senders and receivers are in separate
> namespaces.
> 
> Without this patchset we can report the wrong pid and uid
> values in our unix domain credentials.
> 
> As a finally this patchset removes the now unnecessary restriction
> that we only allow unix domain sockets between processes in the
> same network namespace.

Looks good, all applied to net-next-2.6, thanks Eric.
