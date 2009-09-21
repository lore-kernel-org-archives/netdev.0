From: John Ronciak <john.ronciak@gmail.com>
Subject: Re: SO_TIMESTAMPING fix and design decisions
Date: Mon, 21 Sep 2009 10:59:34 -0700
Message-ID: <56a8daef0909211059q49b96dd5pc2f3e81b8dad6c2@mail.gmail.com>
References: <20090919192549.0735c93a@pundit>
	 <1253398161.14869.2.camel@localhost.localdomain>
	 <20090920095242.5cd42f1a@pundit>
	 <1253468893.2654.6.camel@localhost.localdomain>
	 <20090920205047.0f2df70c@pundit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Christopher Zimmermann <madroach@zakweb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f171.google.com ([209.85.216.171]:50852 "EHLO
	mail-px0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbZIUR7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2009 13:59:30 -0400
Received: by pxi1 with SMTP id 1so2614921pxi.1
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2009 10:59:34 -0700 (PDT)
In-Reply-To: <20090920205047.0f2df70c@pundit>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 20, 2009 at 11:50 AM, Christopher Zimmermann
<madroach@zakweb.de> wrote:
> It will need to be modified. If you want to avoid this, one could keep
> the HWTSTAMP_FILTER_PTP_.... defines and just redifine them to reflect
> the new interface.
> Where can I find this ptpd userspace daemon, which supports hardware
> timestamps using the ioctl interface? ptpd.sourceforge.net doesn't.
You can find a version of the modified ptpd on the e1000 Sourceforge
site http://e1000.sf.net.  It has a version of the igb driver that
also supports this interface though it's a bit behind the regular igb
driver version.

I'm review your comments that start this thread and should have some
comments soon.

-- 
Cheers,
John
