From: Arun MURTHY <arun.murthy@stericsson.com>
Subject: RE: [PATCHv2 3/4] modem_shm: u8500-shm: U8500 Shared Memory Driver
Date: Wed, 8 Aug 2012 05:36:22 +0200
Message-ID: <F45880696056844FA6A73F415B568C695B0E796A04@EXDCVYMBSTM006.EQ1STM.local>
References: <1344322471-3640-1-git-send-email-arun.murthy@stericsson.com>
 <1344322471-3640-4-git-send-email-arun.murthy@stericsson.com>
 <20120807183925.GD26990@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Sjur BRENDELAND <sjur.brandeland@stericsson.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20120807183925.GD26990@kroah.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >  drivers/modem_shm/Kconfig                        |    2 +
> >  drivers/modem_shm/Makefile                       |    1 +
> >  drivers/modem_shm/u8500_shm/Kconfig              |   43 +
> >  drivers/modem_shm/u8500_shm/Makefile             |    7 +
> >  drivers/modem_shm/u8500_shm/shrm_char.c          |  895 ++++++++++++
> >  drivers/modem_shm/u8500_shm/shrm_driver.c        |  732 ++++++++++
> >  drivers/modem_shm/u8500_shm/shrm_fifo.c          |  837 ++++++++++++
> >  drivers/modem_shm/u8500_shm/shrm_net.c           |  312 +++++
> >  drivers/modem_shm/u8500_shm/shrm_protocol.c      | 1590
> ++++++++++++++++++++++
> >  include/linux/modem_shm/u8500_shm/shrm.h         |   23 +
> >  include/linux/modem_shm/u8500_shm/shrm_config.h  |  114 ++
> >  include/linux/modem_shm/u8500_shm/shrm_driver.h  |  225 +++
> >  include/linux/modem_shm/u8500_shm/shrm_ioctl.h   |   43 +
> >  include/linux/modem_shm/u8500_shm/shrm_net.h     |   46 +
> >  include/linux/modem_shm/u8500_shm/shrm_private.h |  183 +++
> 
> Why do any of those .h files need to be in include/linux/*?  Shouldn't
> they just be in the same directory as the driver itself?

Can be moved to the same dir. Will do that in the next ver of the patch.

Thanks and Regards,
Arun R Murthy
-------------
