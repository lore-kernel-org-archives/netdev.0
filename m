From: =?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Subject: ixp4xx_hss and netif_receive_skb
Date: Tue, 17 Feb 2009 17:02:09 +0100
Message-ID: <b0438a630902170802i4923f131i7210425e4679d0eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:13187 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbZBQQCL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 11:02:11 -0500
Received: by fg-out-1718.google.com with SMTP id 16so457838fgg.17
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 08:02:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi...

I have modified Krzysztof Halasa's driver ixp4xx_hss to allow 4 HLDC
channels per HSS (if anyone is interested, I will post the changes,
but they are not ready for main stream yet).. I am able to transmit
and receive data using it.

The problem is that the received data is not sent to the listening
interface. I can see that netif_receive_skb returns a NET_RX_DROP, but
I loose myself in that point.

I am not sure of what is done in that function or if the desired
behaviour is the "deliver_skb", or the pt_prev->func.

Any clue in where to find some explanation about this function?

Thanks

Miguel =C1ngel =C1lvarez
