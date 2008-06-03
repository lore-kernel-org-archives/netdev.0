From: Greg KH <greg@kroah.com>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs
	interface implementation for the driver
Date: Tue, 3 Jun 2008 11:30:39 -0700
Message-ID: <20080603183039.GA30454@kroah.com>
References: <20080529095126.9943.84692.stgit@localhost.localdomain> <20080529095754.9943.27936.stgit@localhost.localdomain> <20080529103003.010c4a08@extreme> <20080529174805.GA10903@kroah.com> <c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	rdreier@cisco.com, general@lists.openfabrics.org,
	poornima.kamath@qlogic.com
To: Amar Mudrankit <amar.mudrankit@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48717 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbYFCScV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 14:32:21 -0400
Content-Disposition: inline
In-Reply-To: <c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 11:55:00PM +0530, Amar Mudrankit wrote:
> Documentation/filesystems/configfs/configfs.txt <<snip>>
> 
>                   [Using configfs]
> 
>                   Like sysfs, attributes should be ASCII text files, preferably
>                   with only one value per file.  The same efficiency caveats from sysfs
>                   apply.  Don't mix more than one attribute in one attribute file.
> 
> It looks like configfs also does not allow multiple attributes per file.

But you have attribute/value pairs, right?  Just create multiple
attribute files then in configfs for them.

> So, in that case, shall we modify our sysfs code to support one value per
> sysfs file? With this approach, the impact on user space applications that
> we have which depend on the qlgc_vnic driver sysfs interface will be less.

If you want to, but as this looks like it is used for configuration, I
suggest using configfs instead.

thanks,

greg k-h
