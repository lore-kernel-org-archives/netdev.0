From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 10/13] debugfs: constify argument to
 debugfs_real_fops()
Date: Thu, 3 Nov 2016 16:58:22 +0000
Message-ID: <20161103165822.792e95ab@jkicinski-Precision-T1700>
References: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
        <1478181538-20778-11-git-send-email-jakub.kicinski@netronome.com>
        <87zilgv6yc.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christian Lamparter <chunkeey@gmail.com>
To: Nicolai Stange <nicstange@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37670 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbcKCQ61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 12:58:27 -0400
Received: by mail-wm0-f52.google.com with SMTP id t79so113398263wmt.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 09:58:26 -0700 (PDT)
In-Reply-To: <87zilgv6yc.fsf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Nov 2016 17:55:39 +0100, Nicolai Stange wrote:
> Hi Jakub,
> 
> thanks for this.
> 
> However, the debugfs maintainer, Greg K-H, as well as the lkml is
> missing from the To/Cc. Can you resend please?

Sure thing!

> Jakub Kicinski <jakub.kicinski@netronome.com> writes:
> 
> > seq_file users can only access const version of file pointer,  
> 
> ... because the ->file member of struct seq_operations is marked as such.

Thanks!
