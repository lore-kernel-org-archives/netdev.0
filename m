From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register
 accessors
Date: Tue, 16 May 2017 14:43:41 +0200
Message-ID: <20170516124255.GA5440@redhat.com>
References: <20170515134711.2770374-1-arnd@arndb.de>
 <20170515142520.GA13996@redhat.com>
 <20170515.103951.2305484593464882104.davem@davemloft.net>
 <20170516115511.GA4230@redhat.com>
 <1494935936.15923.0.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, arnd@arndb.de,
        helmut.schaa@googlemail.com, kvalo@codeaurora.org,
        daniel@makrotopia.org, dev@kresin.me, pozega.tomislav@gmail.com,
        vasilugin@yandex.ru, roman@advem.lv,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1494935936.15923.0.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 01:58:56PM +0200, Johannes Berg wrote:
> On Tue, 2017-05-16 at 13:55 +0200, Stanislaw Gruszka wrote:
> > 
> > In rt2x00 driver we use poor convention in other kind of registers
> > accessors like bbp, mac, eeprom. I dislike to changing only rfcsr
> > accessors and leaving others in the old way. And changing all
> > accessors would be massive and error prone change, which I'm not
> > prefer either.
> 
> That's a stupid argument, but for the sake of it - the conversion can
> easily be done with coccinelle/spatch without being "error prone".

Sure, but still I think it would be preferable to fix newly added
rt2800_bw_filter_calibration() function, instead of ancient rfcsr
accessors.

Stanislaw  
