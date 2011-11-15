From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
	present
Date: Tue, 15 Nov 2011 12:00:25 -0500
Message-ID: <20111115170018.GB25132@gospo.rdu.redhat.com>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51527 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755643Ab1KORAf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 12:00:35 -0500
Content-Disposition: inline
In-Reply-To: <1321375482-8637-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2011 at 05:44:42PM +0100, Veaceslav Falico wrote:
> When changing mode via bonding's sysfs, the slaves are not initialized
> correctly. Forbid to change modes with slaves present to ensure that every
> slave is initialized correctly via bond_enslave().
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Looks good.  This behavior forces someone who wants to change to mode to
go through steps that are almost as destructive as when module options
are used to configure the mode.  I do not see a problem with this.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
