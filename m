From: Pablo Cholaky <mrwaltercool@gmail.com>
Subject: Re: r8169 Wake on Lan
Date: Wed, 27 Nov 2013 15:32:21 -0300
Message-ID: <CAEv3EXHY6MzeUxmuJKtO51QMa8AirsVbPP5EgWTfNw941Q9i1Q@mail.gmail.com>
References: <CAEv3EXFiUnfkBCiedjXUzc6MXBnP2vqNx4R3739642dGYazTwA@mail.gmail.com>
 <20131126232101.GA7508@electric-eye.fr.zoreil.com> <CAEv3EXFm5MrDeZLRyAZdVNoXWEGB7sU405+oM7K=o=eiAnUNPA@mail.gmail.com>
 <20131126235727.GA8466@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:44195 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228Ab3K0Scn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 13:32:43 -0500
Received: by mail-wi0-f172.google.com with SMTP id en1so7203777wid.11
        for <netdev@vger.kernel.org>; Wed, 27 Nov 2013 10:32:41 -0800 (PST)
In-Reply-To: <20131126235727.GA8466@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That's the logic:

- If I turn off my PC with WOL disabled using ethtool, WOL will be
disabled (normal off, suspend to disk and suspend to RAM).

- If I turn on my PC,  WOL will always be turned on (including from
suspend to disk and suspend to RAM)

A problem with S states you think?
