From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: Use setup_timer instead of init_timer
Date: Mon, 06 Mar 2017 13:26:52 +0100
Message-ID: <1488803212.5761.7.camel@sipsolutions.net>
References: <20170303124535.30125-1-jslaby@suse.cz>
         <1488803104.5761.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        =?UTF-8?Q?Ond=C5=99ej_Lyson=C4=9Bk?= <ondrej.lysonek@seznam.cz>,
        "David S. Miller" <davem@davemloft.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:47178 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753597AbdCFNIr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 08:08:47 -0500
In-Reply-To: <1488803104.5761.6.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-06 at 13:25 +0100, Johannes Berg wrote:
> On Fri, 2017-03-03 at 13:45 +0100, Jiri Slaby wrote:
> > From: Ondřej Lysoněk <ondrej.lysonek@seznam.cz>
> > 
> > Use setup_timer() and setup_deferrable_timer() to set the data and
> > function timer fields. It makes the code cleaner and will allow for
> > easier change of the timer struct internals.
> 
> Btw, I suspect you generated this with coccinelle and didn't put
> enough
> "..." there, because you missed one in mesh_path_new() :)
> 
and perhaps mesh_plink_timer_set()?

johannes
