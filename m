From: Jesse Gross <jesse@nicira.com>
Subject: Re: sky2, vlan and nat/masquerading
Date: Mon, 21 Mar 2011 19:14:40 -0700
Message-ID: <AANLkTinHviwXOLnq3QURocfOgfh7_ZVbRdeHOz4Z6a0g@mail.gmail.com>
References: <20110309181522.61ca1cc7@leda.vpn.lugor.de> <AANLkTi=AJJA0d0=CFuS66=+O6b80Ejj0w3NfKQ+OWzsK@mail.gmail.com>
 <20110314111105.5a62e092@leda.vpn.lugor.de> <AANLkTikXBz6ZpuSgqaAV-=Jr3qtDQ3T_We42R65Sd20O@mail.gmail.com>
 <20110315085326.1a1019aa@leda.vpn.lugor.de> <AANLkTikeVWuDMhws4JX0S+WhKFja8zU_2ZY3KZZUAXks@mail.gmail.com>
 <20110317224044.3ff4fbd8@leda.vpn.lugor.de> <20110318074612.37cfc0d5@leda.vpn.lugor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Christian Hesse <mail@eworm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:53490 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756273Ab1CVCPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 22:15:01 -0400
Received: by qyk7 with SMTP id 7so3034820qyk.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 19:15:00 -0700 (PDT)
In-Reply-To: <20110318074612.37cfc0d5@leda.vpn.lugor.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 17, 2011 at 11:46 PM, Christian Hesse <mail@eworm.de> wrote:
> On Thu, 17 Mar 2011 22:40:44 +0100 Christian Hesse <mail@eworm.de> wrote:
>> On Thu, 17 Mar 2011 12:23:48 -0700 Jesse Gross <jesse@nicira.com> wrote:
>> > Can you try using ethtool to turn off txvlan and see if that makes a
>> > difference?
>>
>> Sure. I will give it a try tomorrow.
>
> No, that does not make a difference.

Hmm, this problem seems very strange to me.  I'm not sure that there
is much more I can do without reproducing the problem and it sounds
like I won't be able to do that on my hardware.

If you're able to, the best thing to do would be insert some debugging
statements along the transmit path to find out exactly where the
additional vlan tag is being inserted.  Although it only happens with
a single driver, it must be occurring in software because the tag
shows up in tcpdump on the transmit side.
