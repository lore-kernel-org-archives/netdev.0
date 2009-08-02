From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [PATCH] pcnet32: remove superfluous NULL pointer check in pcnet32_probe1()
Date: Sun, 2 Aug 2009 22:07:29 +0200
Message-ID: <200908022207.29942.bzolnier@gmail.com>
References: <200907302319.18150.bzolnier@gmail.com> <20090802.123022.148176905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: pcnet32@verizon.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, error27@gmail.com, corbet@lwn.net,
	eteo@redhat.com, julia@diku.dk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:61829 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbZHBUIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 16:08:05 -0400
In-Reply-To: <20090802.123022.148176905.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 02 August 2009 21:30:22 David Miller wrote:
> From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> Date: Thu, 30 Jul 2009 23:19:17 +0200
> 
> > From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> > Subject: [PATCH] pcnet32: remove superfluous NULL pointer check in pcnet32_probe1()
> > 
> > Move the debug printk() into the proper place and remove superfluous
> > NULL pointer check in pcnet32_probe1().
> > 
> > This takes care of the following entry from Dan's list:
> > 
> > drivers/net/pcnet32.c +1889 pcnet32_probe1(298) warning: variable derefenced before check 'pdev'
> > 
> > Reported-by: Dan Carpenter <error27@gmail.com>
> > Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
> 
> Applied, but please CC: netdev@vger.kernel.org for all future
> network driver patches so that it gets properly tracked in
> patchwork.  Thanks!

netdev@vger.kernel.org was on cc: for all patches...

http://marc.info/?l=linux-netdev&m=124898901714229&w=2
http://marc.info/?l=linux-netdev&m=124898901714236&w=2

maybe there is some problem with a patchwork setup..
