From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [Bugme-new] [Bug 10737] New: pktgen procfs problem
Date: Wed, 21 May 2008 01:57:51 +0400
Message-ID: <20080520215751.GB25309@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: robert.olsson@its.uu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.184]:59655 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757852AbYETVCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 17:02:11 -0400
Received: by gv-out-0910.google.com with SMTP id e6so642384gvc.37
        for <netdev@vger.kernel.org>; Tue, 20 May 2008 14:02:10 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > >> +	} else
> > >> +	       module_put(de->owner);
> > >>  	return inode;
> > >>   out_ino:

> Yes it fixes the oops I got as well.
>
> Acked-by: Robert Olsson <robert.olsson@its.uu.se>

Robert, which oops do you see?

Patch you cited hardly can fix an oops (as in real oops, not warning).

