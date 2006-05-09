From: Uli Kunitz <kune@deine-taler.de>
Subject: Re: Scanning in ieee80211 softmac layer and setting essid (newbie)
Date: Wed, 10 May 2006 00:27:57 +0200 (CEST)
Message-ID: <Pine.LNX.4.58.0605100025510.17506@p15091797.pureserver.info>
References: <d0383f90605090638u3ca7a5c0je1a4ce8bc3dc696e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:445 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751247AbWEIW17 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 May 2006 18:27:59 -0400
To: Ian Brown <ianbrn@gmail.com>
In-Reply-To: <d0383f90605090638u3ca7a5c0je1a4ce8bc3dc696e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian Brown wrote:

> My question is : why is this scanning needed when set essid is called?
> and why is the repeatition?

ESSID doesn't tell you the channel nummber, so you have to scan
for a beacon containing the ESSID in passive scanning. Even if you
do active scanning you need to check all channels because your
ESSID could be on anyone of the channels.

Uli

-- 
Uli Kunitz - kune@deine-taler.de
