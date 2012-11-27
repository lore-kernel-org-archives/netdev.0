From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH 2/2] smsc75xx: support PHY wakeup source
Date: Tue, 27 Nov 2012 17:23:15 +0000
Message-ID: <CAKh2mn4xfpO-vMZGnikuS29xrCc_XJMGu0gexyn1EBeG4prgog@mail.gmail.com>
References: <1354026482-10443-1-git-send-email-steve.glendinning@shawell.net>
	<1354026482-10443-3-git-send-email-steve.glendinning@shawell.net>
	<1354031804.2116.8.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:35405 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756244Ab2K0RXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 12:23:22 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so4926870eaa.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 09:23:16 -0800 (PST)
In-Reply-To: <1354031804.2116.8.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On 27 November 2012 15:56, Joe Perches <joe@perches.com> wrote:
> On Tue, 2012-11-27 at 14:28 +0000, Steve Glendinning wrote:
>> +     ret = smsc75xx_read_reg_nopm(dev, PMT_CTL, &val);
>> +     check_warn_return(ret, "Error reading PMT_CTL");
>
> Hi Steve, can you please add newlines to these new
> check_warn_<foo> messages and the netdev_<level> ones too?
> It helps avoid message interleaving.

Sorry about that, I did see your earlier patch to fix existing instances.

David: please discard this patch too, I'll resubmit.
