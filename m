From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: move veth.h to include/linux
Date: Tue, 25 Dec 2007 17:19:34 -0800 (PST)
Message-ID: <20071225.171934.74108063.davem@davemloft.net>
References: <20071225124656.723c2db6@deepthought>
	<20071225222335.GA5927@uranus.ravnborg.org>
	<20071225171415.7b7cfc56@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sam@ravnborg.org, vgusev@openvz.org, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39603
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751307AbXLZBTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Dec 2007 20:19:43 -0500
In-Reply-To: <20071225171415.7b7cfc56@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Tue, 25 Dec 2007 17:14:15 -0800

> On Tue, 25 Dec 2007 23:23:35 +0100
> Sam Ravnborg <sam@ravnborg.org> wrote:
> 
> > Someone will argue that you should use header-y +=
> > because the file has no conditionals removed by unifdef.
> > 
> > My personal opinion is that we should kill header-y and
> > I had patches to greatly improve all this but they got 
> > lost by accident and I have not yet redone them.
> > 
> > 	Sam
> 
> Someone might add kernel code later...

I doubt it, I'll therefore modify your patch to use
header-y for now.
