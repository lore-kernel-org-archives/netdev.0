From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: net-next: 2.6.34-rc1 regression: panic when running diagnostic
 on interface with IPv6
Date: Sun, 11 Apr 2010 21:49:19 -0700 (PDT)
Message-ID: <18279548.81981271047759991.JavaMail.root@tahiti.vyatta.com>
References: <EA929A9653AAE14F841771FB1DE5A1365FE4F6B7C4@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Emil S Tantilov <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55894 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082Ab0DLEto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 00:49:44 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE4F6B7C4@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- "Emil S Tantilov" <emil.s.tantilov@intel.com> wrote:

> Stephen Hemminger wrote:
> > Send me your kernel config. And are you running tests online or
> > offline 
> 
> Config attached. The kernel runs on top of RHEL5.4, not sure if that
> is significant, but should explain some of the sysfs deprecated
> options enabled in it. 
> 
> The test is offline (online doesn't do much other than link check).
> 
> I also reproduced it with a fresh pull from this morning. Looks like
> it is easier to reproduce after you pass some traffic, just assigning
> IPv6 address may not be enough. Also rmmod hangs.
> 
> Thanks,
> Emil

I have a fix, but it needs more testing.
