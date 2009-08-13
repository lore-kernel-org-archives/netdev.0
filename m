From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Iproute2]: failed replacing internal netem qdisc with pfifo
Date: Thu, 13 Aug 2009 12:03:30 +0000
Message-ID: <20090813120330.GB7010@ff.dom.local>
References: <2036847082.914731250159200857.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Marcela Maslanova <mmaslano@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:48532 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbZHMMDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 08:03:35 -0400
Received: by bwz22 with SMTP id 22so536437bwz.18
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 05:03:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <2036847082.914731250159200857.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-08-2009 12:26, Marcela Maslanova wrote:
> Hello,
> I've received bug report about not being replaced netem with pfifo
> anymore: https://bugzilla.redhat.com/show_bug.cgi?id=515522
> This should be possible according to documentation [1].
> Is this intentional change or is it a bug?

It's intentional:
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=02201464119334690fe209849843881b8e9cfa9f

> 
> It worked with kernel-2.6.27.5-117.fc10 and iproute-2.6.27. The problem
> is still present with current iproute and kernel-2.6.29.6-217.2.3.fc11.

Yes, netem is classless since 2.6.29, so this documentation needs
updating.

Best regards,
Jarek P.
