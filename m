From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv2 3/4] modem_shm: u8500-shm: U8500 Shared Memory Driver
Date: Tue, 7 Aug 2012 11:39:25 -0700
Message-ID: <20120807183925.GD26990@kroah.com>
References: <1344322471-3640-1-git-send-email-arun.murthy@stericsson.com>
 <1344322471-3640-4-git-send-email-arun.murthy@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, sjur.brandeland@stericsson.com
To: Arun Murthy <arun.murthy@stericsson.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1344322471-3640-4-git-send-email-arun.murthy@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2012 at 12:24:30PM +0530, Arun Murthy wrote:
> The communication between APE and CMT in u8500 is by means of a shared DDR.
> Since its a shared memory, this driver implements shrm protocol.
> 
> Signed-off-by: Arun Murthy <arun.murthy@stericsson.com>
> Acked-by: Linus Walleij <linus.walleij@stericsson.com>
> ---
>  drivers/modem_shm/Kconfig                        |    2 +
>  drivers/modem_shm/Makefile                       |    1 +
>  drivers/modem_shm/u8500_shm/Kconfig              |   43 +
>  drivers/modem_shm/u8500_shm/Makefile             |    7 +
>  drivers/modem_shm/u8500_shm/shrm_char.c          |  895 ++++++++++++
>  drivers/modem_shm/u8500_shm/shrm_driver.c        |  732 ++++++++++
>  drivers/modem_shm/u8500_shm/shrm_fifo.c          |  837 ++++++++++++
>  drivers/modem_shm/u8500_shm/shrm_net.c           |  312 +++++
>  drivers/modem_shm/u8500_shm/shrm_protocol.c      | 1590 ++++++++++++++++++++++
>  include/linux/modem_shm/u8500_shm/shrm.h         |   23 +
>  include/linux/modem_shm/u8500_shm/shrm_config.h  |  114 ++
>  include/linux/modem_shm/u8500_shm/shrm_driver.h  |  225 +++
>  include/linux/modem_shm/u8500_shm/shrm_ioctl.h   |   43 +
>  include/linux/modem_shm/u8500_shm/shrm_net.h     |   46 +
>  include/linux/modem_shm/u8500_shm/shrm_private.h |  183 +++

Why do any of those .h files need to be in include/linux/*?  Shouldn't
they just be in the same directory as the driver itself?

greg k-h
