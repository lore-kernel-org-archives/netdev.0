From: Darren Hart <dvhart@infradead.org>
Subject: Re: [PATCH 0/7][RFC] FUJITSU Extended Socket network device driver
Date: Wed, 20 May 2015 16:47:11 +0200
Message-ID: <20150520144711.GE22037@vmdeb7>
References: <E86EADE93E2D054CBCD4E708C38D364A5422D803@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>,
	"Hart, Darren" <darren.hart@intel.com>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
To: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E86EADE93E2D054CBCD4E708C38D364A5422D803@G01JPEXMBYT01>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 20, 2015 at 08:04:07AM +0000, Izumi, Taku wrote:
> Hi All,
> 
> This patchsets add support for FUJITSU Extended Socket network
> device. Extended Socket network device is a shared memory
> based high-speed network interface between Extended Partitions of
> PRIMEQUEST 2000 E2 series.

Hi Taku,

A few things to keep in mind.

1) Always Cc the maintainer using the email address in the MAINTAINERS file,
   in this case, dvhart at infradead.org.

2) See Documentation/email-clients.txt regarding charset (you sent ISO-2022,JP):

   Email clients should not modify the character set encoding of the text.
   Emailed patches should be in ASCII or UTF-8 encoding only.
   If you configure your email client to send emails with UTF-8 encoding,
   you avoid some possible charset problems.

3) A new driver should be functional at each patch point, so committing a
   skeleton that does nothing is not what we're looking for by "small functional
   changes".

Thanks,

-- 
Darren Hart
Intel Open Source Technology Center
