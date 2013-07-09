From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Extremely bad performance with RTL8111/8168B
Date: Mon, 08 Jul 2013 17:12:32 -0700
Message-ID: <1373328752.4979.129.camel@edumazet-glaptop>
References: <20130708095459.GA29788@amd.pavel.ucw.cz>
	 <1373291269.4979.102.camel@edumazet-glaptop>
	 <20130708220149.GA15766@electric-eye.fr.zoreil.com>
	 <20130709000902.GB19366@amd.pavel.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:60625 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753400Ab3GIAMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 20:12:34 -0400
Received: by mail-ob0-f176.google.com with SMTP id v19so6271663obq.35
        for <netdev@vger.kernel.org>; Mon, 08 Jul 2013 17:12:34 -0700 (PDT)
In-Reply-To: <20130709000902.GB19366@amd.pavel.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-09 at 02:09 +0200, Pavel Machek wrote:

> BTW I'm on 100mbit switch, so advanced stuff needed for gigabit speed
> is not too important for me. I may want to connect it with cross cable
> in future, but for now...



Check "ethtool eth0" and make sure you are in full-duplex mode.
