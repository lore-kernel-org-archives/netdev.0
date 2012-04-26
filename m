From: Steve Glendinning <steve@shawell.net>
Subject: Re: [PATCH v2] smsc95xx: mark link down on startup and let PHY
 interrupt deal with carrier changes
Date: Thu, 26 Apr 2012 10:41:33 +0100
Message-ID: <CAKh2mn6YM=Jmpmfr7ErM0cRjsMc97DzoBLcA45gh9yzSpQDRJg@mail.gmail.com>
References: <1335189920-31062-1-git-send-email-paolo.pisati@canonical.com>
	<20120423194339.GS5277@charybde.local>
	<20120424.004240.51699724664176823.davem@davemloft.net>
	<CAKh2mn4JLm8f036d7vNimLdA2wCP+Db7xhgUgfsg760yhs3Yjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: fillods@users.sf.net, paolo.pisati@canonical.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f51.google.com ([209.85.210.51]:33134 "EHLO
	mail-pz0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209Ab2DZJle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:41:34 -0400
Received: by dadz8 with SMTP id z8so1332502dad.10
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 02:41:33 -0700 (PDT)
In-Reply-To: <CAKh2mn4JLm8f036d7vNimLdA2wCP+Db7xhgUgfsg760yhs3Yjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

On 24 April 2012 16:45, Steve Glendinning <steve@shawell.net> wrote:
> Hi all,
>
> On 24 April 2012 05:42, David Miller <davem@davemloft.net> wrote:
>>
>> Steve, please send a maintainers etc. update and please provide
>> feedback on this link status fix.

Good catch Paolo, this patch fixes reporting of link status when the
device is first connected with no ethernet cable plugged in.

I'll prepare the same patch for smsc75xx as it also suffers from the same issue.

Acked-by: Steve Glendinning <steve.glendinning@shawell.net>

-- 
Steve Glendinning
