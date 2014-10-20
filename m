From: Cong Wang <cwang@twopensource.com>
Subject: Re: Adding new packet scheduler
Date: Mon, 20 Oct 2014 10:59:10 -0700
Message-ID: <CAHA+R7P-dnBd=25_EtD8WY1qThtHRS1Rmu1Y0m0P2WdjoCrCBg@mail.gmail.com>
References: <CAHmvzZQALDuwMPZC_ZncEP=BerniYis9Mx=oObUGNAY4wUGTZg@mail.gmail.com>
	<CAHA+R7PScLKyhF7V+RWahL1Ovfjb7eCO+Hh-aDYchPrfvAUDHg@mail.gmail.com>
	<CAHmvzZS3bN1qErryz7Mps-dOveBk1_d7MJo-sqbVDMaoeu7_HA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Josh Clark <jcinma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:63330 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaJTR7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 13:59:12 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so4047656qcv.38
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 10:59:11 -0700 (PDT)
In-Reply-To: <CAHmvzZS3bN1qErryz7Mps-dOveBk1_d7MJo-sqbVDMaoeu7_HA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2014 at 10:51 AM, Josh Clark <jcinma@gmail.com> wrote:
>
> That all makes a lot of sense. What do I need to do to apply these
> patches on a live system? I have access to a network made of virtual
> machines with standard Ubuntu 14.04, to which I have SSH access.
> There's no way for me to upload a different image to use.

https://www.kernel.org/doc/Documentation/networking/netdev-FAQ.txt

Q: How do the changes posted to netdev make their way into Linux?

A: There are always two trees (git repositories) in play.  Both are driven
   by David Miller, the main network maintainer.  There is the "net" tree,
   and the "net-next" tree.  As you can probably guess from the names, the
   net tree is for fixes to existing code already in the mainline tree from
   Linus, and net-next is where the new code goes for the future release.
   You can find the trees here:

http://git.kernel.org/?p=linux/kernel/git/davem/net.git
http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git
