From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH net-next v2 0/4] 6lowpan: Various bug fixes
Date: Fri, 6 Jul 2012 13:17:56 +0400
Message-ID: <CAJmB2rDZCNDtXYK9UNx-1Hy=Q-JdQcg1ub-ApR6mHJz=YXqCVg@mail.gmail.com>
References: <1341550225-13112-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:46231 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378Ab2GFJR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 05:17:58 -0400
Received: by lbbgm6 with SMTP id gm6so14779032lbb.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 02:17:57 -0700 (PDT)
In-Reply-To: <1341550225-13112-1-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> After reading and playing with the 6lowpan code, I found out a few issues. This
> patchset fixes them. This patchset should apply cleanly against the current
> net-next. It contains only bug fixes, I'll send later on an other patchset that
> will contain new functionalities.
>
> Alexander commented on the previous version of this patchset and made me
> understand that the commit messages were not specific enough. This new version
> hopefully improves that.
>
> This is a set of 4 small patches that correct bugs in 6lowpan:
> - patch 1 fixes a potential crash when reassembling UDP fragments
> - patch 2 fixes a type length issues that prevent the fragmentation reassembly
>   to operate properly.
> - patch 3 and 4 corrects field encoding issues (byte order was not right)
>
> Hope it helps.

Looks good.

Just one note. Please add the project name into the header of your
patches, something like:

6lowpan: blablabla
