From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/8] cxgb4: Add support to recognize 40G links
Date: Thu, 20 Feb 2014 11:00:06 -0800
Message-ID: <CAGVrzcbb-7sQqHyf8SS8-mUyD+LM==Z6r3Zy1rFQ72WHFveMcQ@mail.gmail.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
 <1392726375-32001-2-git-send-email-hariprasad@chelsio.com>
 <53051E48.9050901@opengridcomputing.com> <53064459.3030106@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steve Wise <swise@opengridcomputing.com>,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, dm@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:51740 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbaBTTAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 14:00:50 -0500
Received: by mail-pb0-f48.google.com with SMTP id rr13so2286908pbb.35
        for <netdev@vger.kernel.org>; Thu, 20 Feb 2014 11:00:48 -0800 (PST)
In-Reply-To: <53064459.3030106@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-02-20 10:07 GMT-08:00 Casey Leedom <leedom@chelsio.com>:
>
> On 02/19/14 13:12, Steve Wise wrote:
>>
>>
>> You probably should add SPEED_40000 to include/uapi/linux/ethtool.h as
>> part of this series.
>
>
>   I'm ~pretty sure~ that the "word on the street" was that the community
> wanted to get away from the SPEED_XXX symbols since they simply represented
> the values XXX.  Thus they didn't offer any real symbolic isolation from
> weird constants, etc.  I believe that the old SPEED_XXX values were left in
> place in order to avoid making tons of changes everywhere ...

Not quite sure where and when you heard that, it seems a little
disturbing to add a comment in this patch saying "this I how I should
fix things" and not do them, especially when this is a one-liner.
Having a well defined constant is easier to grep than having the
open-coded 40000 constant which will lead to false positives
throughout the tree.
--
Florian
