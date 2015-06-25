From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH v2 00/22] FUJITSU Extended Socket network device driver
Date: Thu, 25 Jun 2015 00:32:53 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A542440AB@G01JPEXMBYT01>
References: <1435114351-6961-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <20150624154113.4b41db79@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>,
	"dvhart@infradead.org" <dvhart@infradead.org>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"joe@perches.com" <joe@perches.com>,
	"yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <20150624154113.4b41db79@redhat.com>
Content-Language: ja-JP
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Thanks for your comment.

> -----Original Message-----
> From: platform-driver-x86-owner@vger.kernel.org [mailto:platform-driver-x86-owner@vger.kernel.org] On Behalf Of Jesper
> Dangaard Brouer
> Sent: Wednesday, June 24, 2015 10:41 PM
> To: Izumi, Taku/泉 拓
> Cc: brouer@redhat.com; netdev@vger.kernel.org; platform-driver-x86@vger.kernel.org; dvhart@infradead.org;
> rkhan@redhat.com; alexander.h.duyck@redhat.com; linux-acpi@vger.kernel.org; joe@perches.com; yasu.isimatu@gmail.com
> Subject: Re: [PATCH v2 00/22] FUJITSU Extended Socket network device driver
> 
> On Wed, 24 Jun 2015 11:52:31 +0900
> Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:
> 
> > This patchsets adds FUJITSU Extended Socket network device driver.
> > Extended Socket network device is a shared memory based high-speed network
> > interface between Extended Partitions of PRIMEQUEST 2000 E2 series.
> >
> > You can get some information about Extended Partition and Extended
> > Socket by referring the following manual.
> >
> > http://globalsp.ts.fujitsu.com/dmsp/Publications/public/CA92344-0537.pdf
> >   3.2.1 Extended Partitioning
> >   3.2.2 Extended Socket
> >
> > v1 -> v2:
> >   - Location change
> >     drivers/platform/x86 => driver/net
> 
> Could/should this driver be placed under driver/net/ethernet/fujitsu ??
> 
> You are using Ethernet addresses but they are kind of special, always
> 02:00:00:00:00:xx which is hard-coded... maybe I misunderstand the
> code/hw and it is not Ethernet?

  "Extended Socket network device" doesn't necessitate real (physical) Ethernet card.
  There's no Ethernet card, so I'm not quite sure I can put this code
  under driver/net/ethernet.
  I thought this driver is analogous with "vmxnet3" or "hyperv", so I put at driver/net.
  If it's no problem to put it under driver/net/ethernet, I'm ready to migrate it.

  Sincerely,
  Taku Izumi
> 
> [...]
> >  drivers/net/fjes/Makefile       |   31 +
> >  drivers/net/fjes/fjes.h         |   77 +++
> >  drivers/net/fjes/fjes_ethtool.c |  135 ++++
> >  drivers/net/fjes/fjes_hw.c      | 1122 +++++++++++++++++++++++++++++++
> >  drivers/net/fjes/fjes_hw.h      |  333 ++++++++++
> >  drivers/net/fjes/fjes_main.c    | 1397 +++++++++++++++++++++++++++++++++++++++
> >  drivers/net/fjes/fjes_regs.h    |  142 ++++
> >  9 files changed, 3246 insertions(+)
> >  create mode 100644 drivers/net/fjes/Makefile
> >  create mode 100644 drivers/net/fjes/fjes.h
> >  create mode 100644 drivers/net/fjes/fjes_ethtool.c
> >  create mode 100644 drivers/net/fjes/fjes_hw.c
> >  create mode 100644 drivers/net/fjes/fjes_hw.h
> >  create mode 100644 drivers/net/fjes/fjes_main.c
> >  create mode 100644 drivers/net/fjes/fjes_regs.h
> >
> 
> 
> 
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
> --
> To unsubscribe from this list: send the line "unsubscribe platform-driver-x86" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
