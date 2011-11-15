From: David Decotigny <david.decotigny@google.com>
Subject: Re: [PATCH net-next v4 6/8] forcedeth: account for dropped RX frames
Date: Tue, 15 Nov 2011 14:35:08 -0800
Message-ID: <CAG88wWa4Un2iwcFthxxVmeguPpQciovRd4+QqF_L=pxQ1f3vdw@mail.gmail.com>
References: <cover.1321384662.git.david.decotigny@google.com>
 <005cae310e19433c9f68c178805f16c774e8dedd.1321384662.git.david.decotigny@google.com>
 <20111115142130.796d52c3@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63821 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757504Ab1KOWf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 17:35:29 -0500
Received: by iage36 with SMTP id e36so9033282iag.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 14:35:28 -0800 (PST)
In-Reply-To: <20111115142130.796d52c3@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Tue, Nov 15, 2011 at 2:21 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> There is already an rx_dropped statistic in netdevice structure,
> why do you need your own in ethtool?

Sorry, I think my commit message was (once again) inaccurate. This
commit doesn't really "add" the stat, instead it adds code to update
the standard stats (struct rtnl_link_stats64).

Regards,
