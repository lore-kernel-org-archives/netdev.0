From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH v2.2 01/22] fjes: Introduce FUJITSU Extended Socket
 Network Device driver
Date: Fri, 21 Aug 2015 06:11:12 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A54269C80@G01JPEXMBYT01>
References: <1440060306-13040-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <20150820.154901.1696097888673162441.davem@davemloft.net>
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
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <20150820.154901.1696097888673162441.davem@davemloft.net>
Content-Language: ja-JP
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear David,

 Thank you for reviewing.
 I'll update patchset according to your comment.

 Sincerely,
 Taku Izumi

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Friday, August 21, 2015 7:49 AM
> To: Izumi, Taku/泉 拓
> Cc: netdev@vger.kernel.org; platform-driver-x86@vger.kernel.org; dvhart@infradead.org; rkhan@redhat.com;
> alexander.h.duyck@redhat.com; linux-acpi@vger.kernel.org; joe@perches.com; sergei.shtylyov@cogentembedded.com;
> stephen@networkplumber.org; yasu.isimatu@gmail.com
> Subject: Re: [PATCH v2.2 01/22] fjes: Introduce FUJITSU Extended Socket Network Device driver
> 
> From: Taku Izumi <izumi.taku@jp.fujitsu.com>
> Date: Thu, 20 Aug 2015 17:46:05 +0900
> 
> > +obj-$(CONFIG_FUJITSU_ES) += fjes.o
> > +
> > +fjes-objs := fjes_main.o
> > +
> 
> Please do not have trailing empty lines in any files you add
> or edit, 'git' warns about this even when applying patches.
> 
> > +static int fjes_acpi_add(struct acpi_device *device)
> > +{
> > +	acpi_status status;
> > +	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL};
> > +	union acpi_object *str;
> > +	char str_buf[sizeof(FJES_ACPI_SYMBOL) + 1];
> > +	int result;
> > +	struct platform_device *plat_dev;
> 
> Please order your local variables in "reverse christmas tree" order, which
> means longer lines come before shorter ones.
> 
> Please correct this problem in your entire submission, as I am not going
> to point out each and every other place where this problem exists.
