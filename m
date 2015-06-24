From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 00/22] FUJITSU Extended Socket network device driver
Date: Wed, 24 Jun 2015 15:41:13 +0200
Message-ID: <20150624154113.4b41db79@redhat.com>
References: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com, yasu.isimatu@gmail.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 Jun 2015 11:52:31 +0900
Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:

> This patchsets adds FUJITSU Extended Socket network device driver.
> Extended Socket network device is a shared memory based high-speed network
> interface between Extended Partitions of PRIMEQUEST 2000 E2 series.
> 
> You can get some information about Extended Partition and Extended
> Socket by referring the following manual.
> 
> http://globalsp.ts.fujitsu.com/dmsp/Publications/public/CA92344-0537.pdf
>   3.2.1 Extended Partitioning
>   3.2.2 Extended Socket
> 
> v1 -> v2:
>   - Location change
>     drivers/platform/x86 => driver/net

Could/should this driver be placed under driver/net/ethernet/fujitsu ??

You are using Ethernet addresses but they are kind of special, always
02:00:00:00:00:xx which is hard-coded... maybe I misunderstand the
code/hw and it is not Ethernet?

[...]
>  drivers/net/fjes/Makefile       |   31 +
>  drivers/net/fjes/fjes.h         |   77 +++
>  drivers/net/fjes/fjes_ethtool.c |  135 ++++
>  drivers/net/fjes/fjes_hw.c      | 1122 +++++++++++++++++++++++++++++++
>  drivers/net/fjes/fjes_hw.h      |  333 ++++++++++
>  drivers/net/fjes/fjes_main.c    | 1397 +++++++++++++++++++++++++++++++++++++++
>  drivers/net/fjes/fjes_regs.h    |  142 ++++
>  9 files changed, 3246 insertions(+)
>  create mode 100644 drivers/net/fjes/Makefile
>  create mode 100644 drivers/net/fjes/fjes.h
>  create mode 100644 drivers/net/fjes/fjes_ethtool.c
>  create mode 100644 drivers/net/fjes/fjes_hw.c
>  create mode 100644 drivers/net/fjes/fjes_hw.h
>  create mode 100644 drivers/net/fjes/fjes_main.c
>  create mode 100644 drivers/net/fjes/fjes_regs.h
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
