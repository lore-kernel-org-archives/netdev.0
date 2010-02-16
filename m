From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next PATCH v4 1/3] sysctl: refactor integer handling proc code
Date: Tue, 16 Feb 2010 12:48:56 +0200
Message-ID: <201002161248.56598.opurdila@ixiacom.com>
References: <1266271241-6293-1-git-send-email-opurdila@ixiacom.com> <1266271241-6293-2-git-send-email-opurdila@ixiacom.com> <4B7A5A23.3080309@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:9744 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752157Ab0BPKw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 05:52:28 -0500
In-Reply-To: <4B7A5A23.3080309@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 February 2010 10:41:07 you wrote:

> > +
> > +     if (!write && !first && left && !err)
> > +             err = proc_put_newline(&buffer, &left);
> > +     if (write && !err)
> > +             err = proc_skip_wspace(&buffer, &left);
> > +     if (err == -EFAULT /* do we really need to check for -EFAULT? */ ||
> > +         (write && first))
> > +             return err ? : -EINVAL;
> 
> The logic here seems messy, adding one or two goto's may help?
> 

OK, I'll give it a try. 

What about the EFAULT check, is that really required?
