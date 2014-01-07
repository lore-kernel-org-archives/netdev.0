From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Use of 'SIOCDEVPRIVATE' in ethernet drivers.
Date: Tue, 7 Jan 2014 15:44:56 -0800
Message-ID: <20140107154456.7e5af377@nehalam.linuxnetplumber.net>
References: <124064C45E1FC84193A69A61ED3A1F46E22D07@AVMB1.qlogic.org>
	<20140107.140520.1985936966889106257.davem@davemloft.net>
	<124064C45E1FC84193A69A61ED3A1F46E230D6@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Giri Reddy <giri.reddy@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:57412 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875AbaAGXpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 18:45:02 -0500
Received: by mail-pa0-f54.google.com with SMTP id kl14so1049077pab.27
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 15:45:01 -0800 (PST)
In-Reply-To: <124064C45E1FC84193A69A61ED3A1F46E230D6@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Jan 2014 22:22:45 +0000
Giri Reddy <giri.reddy@qlogic.com> wrote:

> On 1/7/14 11:05 AM, David Miller wrote:
> > From: Giri Reddy <giri.reddy@qlogic.com>
> > Date: Tue, 7 Jan 2014 18:21:17 +0000
> >
> >> Are we still allowed to use 'SIOCDEVPRIVATE' in drivers if there the
> >> deprecation efforts are on hold.
> > To say that use of SIOCDEVPRIVATE is discouraged would be an
> > understatement.
> >
> > Please create a generic ethtool based facility that other drivers in
> > similar situations can use as well.
> 
> Thanks for the input. I will explore the 'ethtool' option. We will have
> multiple control frames exchanged between user space and kernel for
> every flash update operation, most of this will be proprietary stuff
> that will get exchanged - I will explore how to provide a generic
> interface for that.
> 
> Giri

Maybe a debugfs or sysfs filesystem would work better than adding ioctl';s
