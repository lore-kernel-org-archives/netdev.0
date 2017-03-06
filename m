From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: Use setup_timer instead of init_timer
Date: Mon, 06 Mar 2017 13:23:42 +0100
Message-ID: <1488803022.5761.5.camel@sipsolutions.net>
References: <20170303124535.30125-1-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        =?UTF-8?Q?Ond=C5=99ej_Lyson=C4=9Bk?= <ondrej.lysonek@seznam.cz>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:47172 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753185AbdCFNIj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 08:08:39 -0500
In-Reply-To: <20170303124535.30125-1-jslaby@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-03-03 at 13:45 +0100, Jiri Slaby wrote:
> From: Ondřej Lysoněk <ondrej.lysonek@seznam.cz>
> 
> Use setup_timer() and setup_deferrable_timer() to set the data and
> function timer fields. It makes the code cleaner and will allow for
> easier change of the timer struct internals.

Applied.

johannes
