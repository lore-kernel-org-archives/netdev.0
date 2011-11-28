From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] netstamp_needed shouldn't be jump_label_key
Date: Mon, 28 Nov 2011 22:45:45 +0100
Message-ID: <1322516745.2970.26.camel@edumazet-laptop>
References: <igorm@etf.rs> <1322511796-6908-1-git-send-email-igorm@etf.rs>
	 <1322511796-6908-2-git-send-email-igorm@etf.rs>
	 <1322512426.2970.15.camel@edumazet-laptop>
	 <1322515010.2970.24.camel@edumazet-laptop>
	 <20111128133142.46998873@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: igorm@etf.rs, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37764 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796Ab1K1Vpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 16:45:50 -0500
Received: by bke11 with SMTP id 11so9103218bke.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 13:45:49 -0800 (PST)
In-Reply-To: <20111128133142.46998873@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 13:31 -0800, Stephen Hemminger a =C3=A9=
crit :

> Why not just change the jump_label_key to a spin_lock? I can't see th=
at it is held
> long enough to make mutex of any benefit.

Because some arches want to use mutex in their
arch_jump_label_transform() or text_poke_smp()
