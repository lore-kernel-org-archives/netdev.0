From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH] wimax: fix kernel-doc for debufs_dentry member of struct wimax_dev [v2]
Date: Thu, 8 Jan 2009 23:23:02 -0800
Message-ID: <200901082323.04014.inaky@linux.intel.com>
References: <1231447827-7999-1-git-send-email-inaky@linux.intel.com> <1231448396-8582-1-git-send-email-inaky@linux.intel.com> <4966E268.20101@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:18688 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751570AbZAIHXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 02:23:20 -0500
In-Reply-To: <4966E268.20101@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 08 January 2009, Randy Dunlap wrote:
> Inaky Perez-Gonzalez wrote:
>...
> > diff --git a/include/net/wimax.h b/include/net/wimax.h
> > index 1602614..073809c 100644
> > --- a/include/net/wimax.h
> > +++ b/include/net/wimax.h
> > @@ -323,6 +323,9 @@ struct input_dev;
> >   *
> >   * @rf_hw: [private] State of the hardware radio switch (OFF/ON)
> >   *
> > + * @debufs_dentry: [private] Used to hook up a debugfs entry. This
> > + *     shows up in the debugfs root as wimax:DEVICENAME.
>
> Inaky, this was supposed to be @debugfs_dentry.  (typo)

Geeze, some days I really really really should not get out of bed and
much less get anywhere near anything with keys, not even a calculator.

Fix available in 
git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git, patch coming.

-- 
Inaky
