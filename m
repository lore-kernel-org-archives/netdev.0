From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: sanity checking iov_iter patches
Date: Thu, 15 Dec 2016 10:00:47 +0100
Message-ID: <20161215100047.7cbe8e61@redhat.com>
References: <20161215062305.GR1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
        David Miller <davem@davemloft.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53618 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755731AbcLOJAv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 04:00:51 -0500
In-Reply-To: <20161215062305.GR1555@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Dec 2016 06:23:05 +0000
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> 	Some of the vfs.git#work.iov_iter stuff touches net/*; basically,
> there are several missing primitives (copy_from_iter_full(), etc.) for
> "try to copy, tell whether it has copied the full amount requested and
> advance the iterator only in case of success".  Most of the callers were
> actually doing just that (see e.g. skb_add_data() and friends) and while
> nothing in the current kernel cares whether we advance ->msg_iter on
> failure, it's much more consistent semantics.
> 
> 	If anybody has objections to that stuff (in linux-next, or in
> git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs.git#work.iov_iter),
> or thinks that some of that should go via net-next.git, yell and I'll
> drop the bits in question.  If not, to Linus it all goes...

Just some links to make it quicker for people see the three patches:
 http://git.kernel.org/cgit/linux/kernel/git/viro/vfs.git/log/?h=work.iov_iter

Patches:
 http://git.kernel.org/cgit/linux/kernel/git/viro/vfs.git/commit/?h=work.iov_iter&id=cbbd26b8b1a
 http://git.kernel.org/cgit/linux/kernel/git/viro/vfs.git/commit/?h=work.iov_iter&id=15e6cb46c9b
 http://git.kernel.org/cgit/linux/kernel/git/viro/vfs.git/commit/?h=work.iov_iter&id=0b62fca2623

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
