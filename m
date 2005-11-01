From: Ian McDonald <imcdnzl@gmail.com>
Subject: Re: [PKT_SCHED]: Rework QoS and/or fair queueing configuration
Date: Wed, 2 Nov 2005 08:54:45 +1300
Message-ID: <cbec11ac0511011154r13e7b695g@mail.gmail.com>
References: <Pine.LNX.4.61.0510280902470.6910@yvahk01.tjqt.qr>
	 <20051031102621.GF8009@stusta.de>
	 <20051031132729.GK23537@postel.suug.ch>
	 <20051101141302.GM23537@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>, bunk@stusta.de,
	jengelh@linux01.gwdg.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751234AbVKATyr@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20051101141302.GM23537@postel.suug.ch>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/11/05, Thomas Graf <tgraf@suug.ch> wrote:
>
> Make "QoS and/or fair queueing" have its own menu, it's too big to be
> inlined into "Network options". Remove the obsolete NET_QOS option.
> Automatically select NET_CLS if needed. Do the same for NET_ESTIMATOR
> but allow it to be selected manually for statistical purposes. Add
> comments to separate queueing from classification. Fix dependencies
> and ordering of classifiers. Improve descriptions/help texts and
> remove outdated pieces.
>
Thomas I think the timing ones can be improved slightly out of the
discussion at here:
http://marc.theaimsgroup.com/?l=linux-netdev&m=112912015311659&w=2

I keep meaning to submit a patch but low on my todo list. Feel free to
do so if you wish or else I will get around to it one day. I know
Arnaldo has also mentioned ktimers for the future (which I haven't yet
read) which may help in this area as well.

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
