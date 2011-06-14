From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] wireless: Remove casts of void *
Date: Tue, 14 Jun 2011 00:19:21 -0700
Message-ID: <1308035961.32499.3.camel@Joe-Laptop>
References: <cover.1308024069.git.joe@perches.com>
	 <337c22b774ff7f007b90b266b25c9a33ff555c48.1308024069.git.joe@perches.com>
	 <BANLkTi=i30Rn7gpCDbn9KKJucq8CB=hssA@mail.gmail.com>
	 <1308029532.26699.68.camel@Joe-Laptop>
	 <BANLkTik4fWbCc8pRZfKCzvKD2f6sK9QCEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-kernel@vger.kernel.org
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTik4fWbCc8pRZfKCzvKD2f6sK9QCEw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-06-14 at 15:39 +1000, Julian Calaby wrote:
> My issue here is that you mention in the commit log that this relates
> to the removal of netdev_priv and dev_priv, but the casts removed
> (mostly) don't.

Sorry if that was unclear to you.

None of these patches remove casts of netdev_priv.

What I meant to say was that net and drivers/net have
had many patches that remove casts of void * like the
patches that removed casts of netdev_priv.

These patches remove the last casts of void * types
in net and drivers/net.

cheers, Joe
