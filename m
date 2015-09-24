From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: Fwd: Delivery Status Notification (Failure)
Date: Thu, 24 Sep 2015 08:50:10 -0400
Message-ID: <20150924125009.GA890@gospo.rdu.cumulusnetworks.com>
References: <047d7b5dbb76a0065405207cfe24@google.com>
 <CAOLDph0pO0q3A4-mRjn3wkGvHP5c9anBWbaDBDOLhVRz+JVDMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Naveen <dear.chap@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:34901 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbbIXMuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 08:50:17 -0400
Received: by qgt47 with SMTP id 47so42832165qgt.2
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 05:50:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAOLDph0pO0q3A4-mRjn3wkGvHP5c9anBWbaDBDOLhVRz+JVDMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 08:03:39AM -0400, Naveen wrote:
> Hi
>      Right now the only way to detect if an interface has a peer(veth)
> is touse ethtool -S. Instead I was thinking of adding it to device
> attributes as a peer_ifndex entry. In drivers/net/veth.c I could add
> an entry to
> dev->groups for a veth specific group. Would that be acceptable ?
> 

I've had similar discussions with others who agree with you that the
current method is not ideal -- especially when there are a large number
of namespaces in in use on a system.  One such proposal was to have the
output in ip link show (possibly only with the '-d' option), but no test
patches have been written yet....
