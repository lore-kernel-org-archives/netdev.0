From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED]: Rework QoS and/or fair queueing configuration
Date: Tue, 01 Nov 2005 22:47:34 +0100
Message-ID: <4367E276.2040406@trash.net>
References: <Pine.LNX.4.61.0510280902470.6910@yvahk01.tjqt.qr>	 <20051031102621.GF8009@stusta.de>	 <20051031132729.GK23537@postel.suug.ch>	 <20051101141302.GM23537@postel.suug.ch> <cbec11ac0511011154r13e7b695g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	bunk@stusta.de, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751301AbVKAVu5@vger.kernel.org>
To: Ian McDonald <imcdnzl@gmail.com>
In-Reply-To: <cbec11ac0511011154r13e7b695g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian McDonald wrote:
> I keep meaning to submit a patch but low on my todo list. Feel free to
> do so if you wish or else I will get around to it one day. I know
> Arnaldo has also mentioned ktimers for the future (which I haven't yet
> read) which may help in this area as well.

AFAIK ktimers are another timer subsystem, but don't provide any
further clock sources. Having higher resolution timers would be
great however for improving accuracy when a qdisc is throttled.
