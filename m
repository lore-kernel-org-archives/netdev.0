From: zhuyj <zyjzyj2000@gmail.com>
Subject: Re: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Thu, 7 Jan 2016 16:35:50 +0800
Message-ID: <568E2366.5090509@gmail.com>
References: <87618083B2453E4A8714035B62D6799250504549@FMSMSX105.amr.corp.intel.com>
 <1452147313-22886-1-git-send-email-zyjzyj2000@gmail.com>
 <20160107065340.GB27753@unicorn.suse.cz> <568E15B6.8010301@gmail.com>
 <20160107075951.GD27753@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, jay.vosburgh@canonical.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	netdev@vger.kernel.org, boris.shteinbock@windriver.com
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35636 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbcAGIf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 03:35:59 -0500
Received: by mail-io0-f169.google.com with SMTP id 77so214159406ioc.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 00:35:58 -0800 (PST)
In-Reply-To: <20160107075951.GD27753@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2016 03:59 PM, Michal Kubecek wrote:
> On Thu, Jan 07, 2016 at 03:37:26PM +0800, zhuyj wrote:
>>> If I read this right, whenever this state (link up but speed/duplex
>>> unknown) is entered, you'll keep writing this message into kernel log
>>> every miimon milliseconds until something changes. I'm not sure how long
>>> a NIC can stay in such state but it might get quite annoying (even more
>>> if something really goes wrong and NIC stays that way which can't be
>>> completely ruled out, IMHO).
>> Sure, Thanks a lot. I want to confirm link_up without link_speed. It
>> is not usual. So I think this only lasts for several seconds.
>> It is very important to us since it can help us to find the root cause.
> For debugging purposes it's fine, of course. But this looked like an
> officially submitted patch so I didn't like the idea of log spamming
> (even one second could result in 10-100 messages and admins certainly
> would hate that).
>
>                                                         Michal Kubecek
>
Thanks a lot.

Zhu Yanjun
