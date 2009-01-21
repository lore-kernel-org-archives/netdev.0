From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: RFC: Mandatory Access Control for sockets aka "personal
 firewalls"
Date: Wed, 21 Jan 2009 09:35:58 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0901210932520.19773@fbirervta.pbzchgretzou.qr>
References: <57962.77.61.51.106.1232522729.squirrel@webmail.xs4all.nl> <e7d8f83e0901210015h5f0f7489u282a50911bf7a988@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rmeijer@xs4all.nl, Casey Schaufler <casey@schaufler-ca.com>,
	Samir Bellabes <sam@synack.fr>, imipak@yahoo.com,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Stephan Peijnik <stephan@peijnik.at>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Peter Dolding <oiaohm@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <e7d8f83e0901210015h5f0f7489u282a50911bf7a988@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2009-01-21 09:15, Peter Dolding wrote:
>
>I really don't see the need for special here other than improving iptables.
>
>LSM module is over kill.  This leads to double processing of packet requests.
>
>netfilter already can operate as either MAC or DAC all depending on
>the rules passed into it and the outside LSM applied.

But it cannot be used for personal firewalls at this time.
Incoming packets have no process context because they are
processed before that is determined, and similarly,
outgoing packets have already left most of the process
context behind them. Additionally, Netfilter cannot reject
bind() calls *at all*. That is the reason this is done
as an LSM in the first place.

