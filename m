From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] netns: add /proc/*/net/id symlink
Date: Sun, 22 May 2011 01:30:54 +0300
Message-ID: <20110521223054.GA3198@p183>
References: <20110521093936.GA3015@p183>
 <m11uzsxdty.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, equinox@diac24.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:47763 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754357Ab1EUWa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 18:30:56 -0400
Received: by ewy4 with SMTP id 4so1477223ewy.19
        for <netdev@vger.kernel.org>; Sat, 21 May 2011 15:30:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <m11uzsxdty.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 21, 2011 at 08:39:37AM -0700, Eric W. Biederman wrote:
> Alexey Dobriyan <adobriyan@gmail.com> writes:
> > * init_net always has id 0
> > * two netns do not have same id
> > * id is unsigned integer
> 
> I don't like this patch because we already have a proc interface
> that already solves this in production kernels today.
> 
> - stat is a single syscall
> - two netns do not have the same id
> - id is an ino_t.

Yeah, stat /proc/*/net/dev works.
If you document this, it means we can't change the way ->low_ino is set.
And we can't do other things inside irregular part of procfs.

But can we add clean interface once in a while.
