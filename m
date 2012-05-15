From: <Sathya.Perla@Emulex.Com>
Subject: RE: Question about be2net error field, rx_drops_no_pbuf
Date: Mon, 14 May 2012 21:28:58 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F64580B0D945@EXMAIL.ad.emulex.com>
References: <4FB17863.5020908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:55581 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755528Ab2EOE3V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 00:29:21 -0400
In-Reply-To: <4FB17863.5020908@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Marcelo Leitner

>What does 'rx_drops_no_pbuf' mean at be2net driver? I can see it is a
>hardware counter for some type of error, which I would like to know
>about. What causes it?
>
>All documentation I could find about it is a comment referring firmware
>specification

Brief descriptions of the counters are in be_ethtool.c:
/* Received packets dropped due to lack of available HW packet buffers
  * used to temporarily hold the received packets.
  */
{DRVSTAT_INFO(rx_drops_no_pbuf)}

pbufs are HW buffers for parking incoming pkts before they are transferred to the host.
You can see this counter go up when the transfer speed of the slot is not fast enough.
lspci -vv?
