From: a1 <a1k@mail.ru>
Subject: Re[4]: e1000 speed/duplex error
Date: Tue, 1 Aug 2006 16:20:06 +0400
Message-ID: <911206621.20060801162006@mail.ru>
References: <1301563340.20060801141827@mail.ru> <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com> <793732866.20060801153230@mail.ru> <9929d2390608010445w4fd81b64g310ae90a423e1a7d@mail.gmail.com>
Reply-To: a1 <a1k@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mail.ru ([194.67.23.121]:43892 "EHLO mx1.mail.ru")
	by vger.kernel.org with ESMTP id S1751265AbWHAMTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 08:19:43 -0400
To: "Jeff Kirsher" <tarbal@gmail.com>
In-Reply-To: <9929d2390608010445w4fd81b64g310ae90a423e1a7d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Jeff.


JK> OPTION 2: Turn auto-negotiate on the e1000 card and tell it to only
JK> advertise 100 Full Duplex.  This will allow negotiation between the
JK> two lnk partners and the e1000 will advertise that it is only able to
JK> do 100 Full duplex.

Is there any way i could do this with ethtool? It only allows force
spd/dplx , but not set it for advertising...

If i do as follows other side reports 1000/FD:

ethtool -s eth0 speed 100 duplex full autoneg on

-- 
Best Regards,
 a1                          mailto:a1k@mail.ru

