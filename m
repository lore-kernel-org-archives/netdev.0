From: stephen mulcahy <smulcahy@gmail.com>
Subject: Re: forcedeth driver hangs under heavy load
Date: Tue, 13 Apr 2010 15:27:04 +0100
Message-ID: <4BC47F38.5040509@gmail.com>
References: <4B9E6C60.7030300@atlanticlinux.ie>	 <20100315182220.GQ2763@decadent.org.uk> <4B9F5E5E.2060209@atlanticlinux.ie>			 <1270393967.8341.11.camel@localhost> <4BBCA19C.5080204@atlanticlinux.ie>			 <1270942606.6179.64.camel@localhost> <4BC2EF88.3060203@atlanticlinux.ie>			 <4BC31486.1090603@gmail.com> <1271076426.16881.21.camel@edumazet-laptop>			 <4BC31AA0.5070006@gmail.com> <4BC31DDE.7010005@gmail.com>			 <1271085862.16881.38.camel@edumazet-laptop> <4BC3461D.3070002@gmail.com>		 <1271091581.16881.41.camel@edumazet-laptop> <4BC44167.4080807@gmail.com>	 <1271155766.16881.245.camel@edumazet-laptop> <4BC44EC8.1010104@gmail.com> <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Ayaz Abdulla <aabdulla@nvidia.com>, 572201@bugs.debian.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep12-int.chello.at ([62.179.121.32]:52488 "EHLO
	viefep12-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071Ab0DMO1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 10:27:16 -0400
In-Reply-To: <1271160298.2098.0.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I've tried both of the following with my reproducer

1. ethtool -K eth0 tso off

RESULT: reproducer causes multiple hosts to be come unresponsive on 
first run.

2. ethtool -K eth0 tx off

RESULT: reproducer runs three times without any hosts becoming unresponsive.

-stephen
