From: =?UTF-8?Q?Nicol=C3=A1s_Sigal_|_LocalHost_Soluci?=
	 =?UTF-8?Q?ones_Innovadoras?= <nicolas.sigal@localhost.net.ar>
Subject: Re: Linux Kernel | Intel Driver Bug - please update
Date: Sat, 20 Aug 2011 17:35:52 -0300
Message-ID: <504DB0A1B3544F7F8719EF324951BBA7@NOTENIKO>
References: <0BE7A0BD7DFE4537AA0C03E333326E52@NOTENIKO> <1311547638.2835.72.camel@jtkirshe-mobl>
Reply-To: =?UTF-8?Q?Nicol=C3=A1s_Sigal_|_LocalHost_Soluci?=
	   =?UTF-8?Q?ones_Innovadoras?= <nicolas.sigal@localhost.net.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <kristoffer@gaisler.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"netdev" <netdev@vger.kernel.org>
To: <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.localhost.net.ar ([200.43.192.6]:60769 "EHLO
	mail.localhost.net.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab1HTUgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 16:36:16 -0400
In-Reply-To: <1311547638.2835.72.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please Jeff, we need the update as soon as possible, we still having cr=
ashes=20
of eth because the driver..

Best regards;

=2E................................................
Nicol=C3=A1s Sigal
CEO :: LocalHost Soluciones Innovadoras
Mendoza 2917 :: C1428DKY
Ciudad Aut=C3=B3noma de Buenos Aires :: Argentina
Tel/Fax: 0810 55 LOCALHOST :: (011) 4784.6993
http://www.localhost.net.ar/
nicolas.sigal@localhost.net.ar

----- Original Message -----=20
=46rom: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
To: "Nicol=C3=A1s Sigal | LocalHost Soluciones Innovadoras"=20
<nicolas.sigal@localhost.net.ar>
Cc: <kristoffer@gaisler.com>; "Brandeburg, Jesse"=20
<jesse.brandeburg@intel.com>; "Allan, Bruce W" <bruce.w.allan@intel.com=
>;=20
"Ronciak, John" <john.ronciak@intel.com>; <support@localhost.net.ar>;=20
"netdev" <netdev@vger.kernel.org>
Sent: Sunday, July 24, 2011 7:47 PM
Subject: Re: Linux Kernel | Intel Driver Bug - please update

On Sun, 2011-07-24 at 13:28 -0700, Nicol=C3=A1s Sigal | LocalHost Soluc=
iones
Innovadoras wrote:
> Please, can you update the e1000e driver of the kernel to v1.4.4?
>
> http://downloadcenter.intel.com/Detail_Desc.aspx?agr=3DY&ProdId=3D329=
9&DwnldID=3D15817&ProductFamily=3DComponentes+Ethernet&ProductLine=3DCo=
ntroladores+Ethernet&ProductProduct=3DControlador+Intel%C2%AE+82579+Gig=
abit+Ethernet&DownloadType=3DControladoresspa
>
> This version have an important bug fixed:
> * 82579: Fix for Tx Hang on FTS ME Platform
>
> And we have this problem in all of our servers with this NIC and ME
> on.
>
> Debug:
>
> Jul 24 14:23:27 [kernel] e1000e 0000:00:19.0: eth0: Detected Hardware
> Unit Hang:
> Jul 24 14:23:27 [kernel]   TDH                  <0>
> Jul 24 14:23:27 [kernel]   TDT                  <16>
> Jul 24 14:23:27 [kernel]   next_to_use          <16>
> Jul 24 14:23:27 [kernel]   next_to_clean        <0>
> Jul 24 14:23:27 [kernel] buffer_info[next_to_clean]:
> Jul 24 14:23:27 [kernel]   time_stamp           <10282156f>
> Jul 24 14:23:27 [kernel]   next_to_watch        <0>
> Jul 24 14:23:27 [kernel]   jiffies              <102821aed>
> Jul 24 14:23:27 [kernel]   next_to_watch.status <0>
> Jul 24 14:23:27 [kernel] MAC Status             <80143>
> Jul 24 14:23:27 [kernel] PHY Status             <796d>
> Jul 24 14:23:27 [kernel] PHY 1000BASE-T Status  <0>
> Jul 24 14:23:27 [kernel] PHY Extended Status    <3000>
> Jul 24 14:23:27 [kernel] PCI Status             <10>
> Jul 24 14:23:28 [kernel] e1000e 0000:00:19.0: eth0: Reset adapter
> Jul 24 14:23:30 [kernel] e1000e: eth0 NIC Link is Up 100 Mbps Full
> Duplex, Flow Control: Rx/Tx
> Jul 24 14:23:30 [kernel] e1000e 0000:00:19.0: eth0: 10/100 speed:
> disabling TSO
>


[removed ixgbe/igb Intel maintainers, and Linus from the email thread]
Added a more appropriate mailing list (netdev)

We currently have the kernel patches in review and testing to update th=
e
e1000e driver to v1.4.4.  I should be able to push some, if not all of
the changes upstream later this week.

