From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] netns: call ops_free right after ops_exit
Date: Sun, 25 Apr 2010 02:59:02 -0700 (PDT)
Message-ID: <20100425.025902.94572342.davem@davemloft.net>
References: <20100425092600.GB2866@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58709
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752498Ab0DYJ65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 05:58:57 -0400
In-Reply-To: <20100425092600.GB2866@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sun, 25 Apr 2010 11:26:01 +0200

> There's no need to iterate this twice. We can free net generic
> variables right after exit is called.
>
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Are you sure there are no problems with doing this?

What if there are inter-net variable reference dependencies
or something like that?

I really suspect it is being done this way on purpose, but
in the end I defer to experts like Eric B. :-)
