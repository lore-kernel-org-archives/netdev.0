From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3 net-next 4/8] net: qualcomm: rename qca_framing.c to
 qca_common.c
Date: Tue, 18 Oct 2016 13:40:04 +0200
Message-ID: <20161018114004.GA19299@kroah.com>
References: <1476790054-27174-1-git-send-email-stefan.wahren@i2se.com>
 <1476790054-27174-5-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Slaby <jslaby@suse.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476790054-27174-5-git-send-email-stefan.wahren@i2se.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2016 at 01:27:30PM +0200, Stefan Wahren wrote:
> As preparation for the upcoming UART driver we need a module
> which contains common functions for both interfaces. The module
> qca_framing is a good candidate but renaming to qca_common would
> make it clear.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
>  drivers/net/ethernet/qualcomm/Makefile      |   2 +-
>  drivers/net/ethernet/qualcomm/qca_common.c  | 156 ++++++++++++++++++++++++++++
>  drivers/net/ethernet/qualcomm/qca_common.h  | 134 ++++++++++++++++++++++++
>  drivers/net/ethernet/qualcomm/qca_framing.c | 156 ----------------------------
>  drivers/net/ethernet/qualcomm/qca_framing.h | 134 ------------------------
>  drivers/net/ethernet/qualcomm/qca_spi.c     |   2 +-
>  drivers/net/ethernet/qualcomm/qca_spi.h     |   2 +-
>  7 files changed, 293 insertions(+), 293 deletions(-)
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_common.c
>  create mode 100644 drivers/net/ethernet/qualcomm/qca_common.h
>  delete mode 100644 drivers/net/ethernet/qualcomm/qca_framing.c
>  delete mode 100644 drivers/net/ethernet/qualcomm/qca_framing.h

'git format-patch -M' is nice when renaming files to show that the files
really are being renamed, and no other changes are being made (or show
the changes easier.)

thanks,

greg k-h
