From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH 7/7] fjes: Add ethtool support
Date: Thu, 21 May 2015 03:30:18 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5422DCDB@G01JPEXMBYT01>
References: <E86EADE93E2D054CBCD4E708C38D364A5422D89B@G01JPEXMBYT01>
 <20150520144347.72bdd228@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <20150520144347.72bdd228@lxorguk.ukuu.org.uk>
Content-Language: ja-JP
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alen,

  Thank you for your comment.

> 1. This driver probably belongs somewhere in drivers/net rather
> than platform-x86

  I was devided between drivers/net and platform-x86...

> 2. It would be helpful to undertand what the use case is. You describe it
> as

    I know. Unfortunately currently there's no good HP to illustrate 
    Extended Socket.

> 
> "This patchsets add support for FUJITSU Extended Socket network
>  device. Extended Socket network device is a shared memory
>  based high-speed network interface between Extended Partitions of
>  PRIMEQUEST 2000 E2 series."
> 
> So would this interface be used to interconnect multiple instances of
> Linxu (or other operating systems) physically partitioned running on the
> PrimeQuest server ?

   This interface is used to interconnect multiple instances of Linux 
   (currently only Linux) LOGICALLY (called Extended Partiton) partitioned
   running PRIMEQUEST.

> Am I looking at the right information about the system here
> 
> http://www.researchgate.net/publication/228905336_Partitioning_Technologies_and_Dynamic_Reconfiguration_of_Mission-C
> ritical_IA_Server_PRIMEQUEST/links/000477b10cf2ed98fb432c1b.pdf

   That document is for PRIMEQUEST 400/500 series, so it's a bit old though basic conception is not so far.

   The following manual is useful to understand Extend Partiton and
   Extended Socket. 

     http://globalsp.ts.fujitsu.com/dmsp/Publications/public/CA92344-0537.pdf
      3.2.1 Extended Partitioning
      3.2.2 Extended Socket

  Sincerely,
  Taku Izumi
     
