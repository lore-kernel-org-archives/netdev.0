From: Antonio Borneo <borneo.antonio-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/6] Remove redundant spi driver bus initialization
Date: Tue, 23 Jun 2015 22:45:08 +0800
Message-ID: <1435070714-24174-1-git-send-email-borneo.antonio@gmail.com>
Cc: Antonio Borneo <borneo.antonio-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>,
	Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, Andrzej Hajda <a.hajda-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>,
	Jonathan Cameron <jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Karol Wrona <k.wrona-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Kyungmin Park <kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Lars-Peter Clausen <lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org>,
	Liam Girdwood <lgirdwood-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-iio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patches-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org,
	Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>,
	Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>,
	Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-iio-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-iio-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This cleanup was already completed between end 2011 and early 2012
with a patch series from Lars-Peter Clausen:
https://lkml.org/lkml/2011/11/24/190

Later on new redundant initialization re-appeared here and there.
Time to cleanup again.

And, yes, I'm lazy! I copy-paste the exact same commit message from
Lars-Peter; only minor reformat to stay in 75 char/line and fix the
name of spi_register_driver().

Regards,
Antonio

Antonio Borneo (6):
  ASoC: wm0010: Remove redundant spi driver bus initialization
  iio: ssp_sensors: Remove redundant spi driver bus initialization
  staging: mt29f_spinand: Remove redundant spi driver bus initialization
  net: ieee802154: Remove redundant spi driver bus initialization
  wireless: cw1200: Remove redundant spi driver bus initialization
  [media] s5c73m3: Remove redundant spi driver bus initialization

 drivers/iio/common/ssp_sensors/ssp_dev.c      | 1 -
 drivers/media/i2c/s5c73m3/s5c73m3-spi.c       | 1 -
 drivers/net/ieee802154/cc2520.c               | 1 -
 drivers/net/ieee802154/mrf24j40.c             | 1 -
 drivers/net/wireless/cw1200/cw1200_spi.c      | 1 -
 drivers/staging/mt29f_spinand/mt29f_spinand.c | 1 -
 sound/soc/codecs/wm0010.c                     | 1 -
 7 files changed, 7 deletions(-)

-- 
2.4.4
