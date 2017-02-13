From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 1/1] gtp: support SGSN-side tunnels
Date: Mon, 13 Feb 2017 15:23:21 +0100
Message-ID: <20170213142321.vkas3kdsc43xs35v@nataraja>
References: <20170203091231.10142-1-jonas@southpole.se>
 <1107124975.65949.1486977919253.JavaMail.zimbra@tpip.net>
 <20170213111640.GA1458@salvia>
 <1384904207.69904.1486986729381.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo <pablo@netfilter.org>, Jonas Bonn <jonas@southpole.se>,
        netdev <netdev@vger.kernel.org>,
        osmocom-net-gprs@lists.osmocom.org
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:42923 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752396AbdBMOXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:23:46 -0500
Content-Disposition: inline
In-Reply-To: <1384904207.69904.1486986729381.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas, Pablo, Jonas,

I think that the SGSN/GGSN role flag (or whatever it may end up being
called) logically belongs in the gtp-device at this point, and will in
the future belong to the UDP/GTP-socket (with Andreas' proposed
changes).   Having it per-pdp-context indeed seems odd and just provide
a way to create broken configurations (and increase the memory use per
pdp context, of which you have many more than netdevs or gtp-sockets).

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
