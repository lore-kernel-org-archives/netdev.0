From: Ajit <ajitsa_bes@yahoo.com>
Subject: Re: Maximum no of bytes Ethernet can transfer at a time ??
Date: Fri, 29 Apr 2011 08:39:31 +0000 (UTC)
Message-ID: <loom.20110429T103558-283@post.gmane.org>
References: <loom.20110427T140651-957@post.gmane.org> <20110427130114.GA1895@hmsreliant.think-freely.org> <loom.20110428T074300-379@post.gmane.org> <20110428110634.GA4165@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:46342 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751510Ab1D2Iju (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2011 04:39:50 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QFjEn-0007wD-80
	for netdev@vger.kernel.org; Fri, 29 Apr 2011 10:39:47 +0200
Received: from mumbai-123-5.primenet.in ([203.115.123.5])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:39:45 +0200
Received: from ajitsa_bes by mumbai-123-5.primenet.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2011 10:39:45 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman <at> tuxdriver.com> writes:


> > 
> Can you just post a link to the code?
> Neil
> 
> > Thank you. 
> > 
> > 

here are the links to the code..

sender code : http://pastebin.com/se17Xn96

The command line arguments are like ./pgm_name eth0 /root/abc

where abc is the file name.

receiver code : http://pastebin.com/AKiUWzwR

just run it.

In the receiver code I have assigned offset to buffer[15], it was just for
debugging purpose. Actually offset must have 16 bits of buffer[15] and
buffer[16], but for files of around 100kb-200kb it will easily work..no need to
modify.

Thank you.

