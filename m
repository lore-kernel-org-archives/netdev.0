From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [net-next PATCH v4 1/3] net: TCP thin-stream detection
Date: Mon, 22 Feb 2010 17:06:25 +0100
Message-ID: <228e2e29ccd24144a77d42cfc5bc72fa@localhost>
References: <20100221102102.GB1311@ucw.cz> <D40945A6-301D-485D-BB8C-826D2EB68DA4@nets.rwth-aachen.de> <2EC47E8B-BC4C-4DAB-86ED-F702D67F8AD0@nokia.com> <20100221.150311.193707249.davem@davemloft.net> <FB5F656F-091A-4FB5-9586-15C6CB263D05@nokia.com> <87k4u5mh9u.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Lars Eggert <lars.eggert@nokia.com>,
	David Miller <davem@davemloft.net>,
	<zimmermann@nets.rwth-aachen.de>, <pavel@ucw.cz>,
	<apetlund@simula.no>, <netdev@vger.kernel.org>,
	<ilpo.jarvinen@helsinki.fi>, <eric.dumazet@gmail.com>,
	<Arnd.Hannemann@nets.rwth-aachen.de>,
	<linux-kernel@vger.kernel.org>, <shemminger@vyatta.com>,
	<william.allen.simpson@gmail.com>, <damian@tvk.rwth-aachen.de>,
	<ebiederm@xmission.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87k4u5mh9u.fsf@basil.nowhere.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 22 Feb 2010 16:17:33 +0100, Andi Kleen <andi@firstfloor.org> wrote:

> Lars Eggert <lars.eggert@nokia.com> writes:

> 

>> If it's off by default there is no issue.

> 

> Still a sufficient large number of people might turn it on

> and then the network would melt.



Then we should apply the same policy as used for the congestion control

algorithms!? Restrict the usage to change the standard behavior via Kconfig

(e.g. menuconfig TCP_CONG_ADVANCED) or even more restricted demand for

CAP_NET_ADMIN.



Hagen
