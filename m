From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] rt2x00: use rt2x00queue_flush_queues() instead of
 implementing the same action
Date: Sun, 8 Mar 2015 11:37:14 +0100
Message-ID: <20150308103713.GA1890@redhat.com>
References: <1425753950-15624-1-git-send-email-giedrius.statkevicius@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: helmut.schaa@googlemail.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giedrius =?utf-8?Q?Statkevi=C4=8Dius?=
	<giedrius.statkevicius@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1425753950-15624-1-git-send-email-giedrius.statkevicius@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 07, 2015 at 08:45:50PM +02iee80211_ops00, Giedrius Statkevi=
=C4=8Dius wrote:
> Use rt2x00queue_flush_queues() in rt2x00mac_flush() instead of
> reimplementing the same actions the second time. Also, now it flushes
> the rx queue aswell which it didn't before and that makes it complete=
ly
> do what it's supposed to do according to struct iee80211_ops: flush()
> must flush all queues.

NACK, RX queue should not be flushed, mac80211 flush is about TX queues
only.

Stanislaw
