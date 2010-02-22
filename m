From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [net-next PATCH v4 1/3] net: TCP thin-stream detection
Date: Mon, 22 Feb 2010 16:17:33 +0100
Message-ID: <87k4u5mh9u.fsf@basil.nowhere.org>
References: <20100221102102.GB1311@ucw.cz>
	<D40945A6-301D-485D-BB8C-826D2EB68DA4@nets.rwth-aachen.de>
	<2EC47E8B-BC4C-4DAB-86ED-F702D67F8AD0@nokia.com>
	<20100221.150311.193707249.davem@davemloft.net>
	<FB5F656F-091A-4FB5-9586-15C6CB263D05@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"zimmermann@nets.rwth-aachen.de" <zimmermann@nets.rwth-aachen.de>,
	"pavel@ucw.cz" <pavel@ucw.cz>,
	"apetlund@simula.no" <apetlund@simula.no>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ilpo.jarvinen@helsinki.fi" <ilpo.jarvinen@helsinki.fi>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"Arnd.Hannemann@nets.rwth-aachen.de"
	<Arnd.Hannemann@nets.rwth-aachen.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"william.allen.simpson@gmail.com" <william.allen.simpson@gmail.com>,
	"damian@tvk.rwth-aachen.de" <damian@tvk.rwth-aachen.de>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>
To: Lars Eggert <lars.eggert@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:60758 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804Ab0BVPRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 10:17:34 -0500
In-Reply-To: <FB5F656F-091A-4FB5-9586-15C6CB263D05@nokia.com> (Lars Eggert's message of "Mon, 22 Feb 2010 08:41:32 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lars Eggert <lars.eggert@nokia.com> writes:

> If it's off by default there is no issue.

Still a sufficient large number of people might turn it on
and then the network would melt.

IMHO TCP changes with badly understood congestion behaviour
should not be merged until the necessary analysis/simulation etc.
is done.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
