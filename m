From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH next 5/6] bonding: Allow userspace to set macaddr on bonding-dev
Date: Fri, 6 Feb 2015 23:11:30 -0800
Message-ID: <CANP3RGfSjRp5wAs8xJiZjkBvC7SyD04pSNosxi9QxeLOGF6qkQ@mail.gmail.com>
References: <1423270316-9311-1-git-send-email-maheshb@google.com>
	<4192.1423272023@famine>
	<CAF2d9jgV5adAjydN18Ct7BVJJcc=FRc+5icNMS=pRQMRX=83+w@mail.gmail.com>
	<4653.1423274042@famine>
	<CAF2d9ji=Z+wVz7AdpSeNmOwys0jqWsx6TYsCML_+Hw=u+QMt_A@mail.gmail.com>
	<7179.1423291742@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <maheshb@google.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:50982 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbbBGHLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 02:11:31 -0500
Received: by mail-qc0-f182.google.com with SMTP id l6so15544640qcy.13
        for <netdev@vger.kernel.org>; Fri, 06 Feb 2015 23:11:30 -0800 (PST)
In-Reply-To: <7179.1423291742@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The worry is about other machines connected to the same switch being able
to sniff/guess-timate enough to be able to flood a switch with LACP packets
and effectively join another machines aggregate, and thus potentially break
another machines network connectivity and/or sniff their traffic and/or spoof
their connectivity.
