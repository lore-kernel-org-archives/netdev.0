From: Bob Copeland <me@bobcopeland.com>
Subject: Re: [ath5k-devel] [PATCH] [ath5k][leds] Ability to disable leds
	support. If leds support enabled do not force mac802.11 leds layer selection.
Date: Wed, 9 Jun 2010 09:58:37 -0400
Message-ID: <AANLkTilrYYHjcMEhhrP7zjcLoo-TNczozxJSNRkDvSZy@mail.gmail.com>
References: <4c0f4326.0a41df0a.7bde.ffffeef2@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ath5k-devel@lists.ath5k.org, Kalle Valo <kalle.valo@iki.fi>,
	linux-wireless@vger.kernel.org,
	GeunSik Lim <geunsik.lim@samsung.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	Keng-Yu Lin <keng-yu.lin@canonical.com>,
	netdev@vger.kernel.org, Jiri Kosina <jkosina@suse.cz>,
	Shahar Or <shahar@shahar-or.co.il>,
	linux-kernel@vger.kernel.org, Luca Verdesca <magooz@salug.it>
To: Dmytro Milinevskyy <milinevskyy@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4c0f4326.0a41df0a.7bde.ffffeef2@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 9, 2010 at 3:31 AM, Dmytro Milinevskyy
<milinevskyy@gmail.com> wrote:
> However if the leds support was enabled do not force selection of 802.11 leds layer.

I don't understand this part.  What's the point of enabling software LEDs
if nothing triggers them?

Also, we can probably build hardware LEDs (hw_set_ledstate) in regardless.
It's a pure register write and doesn't require the rest of the LED machinery.

I assume you are doing this to reduce the size of the module.  If so, can
you include size(1) output in the commit message?

-- 
Bob Copeland %% www.bobcopeland.com
