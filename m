From: Hosam Hittini <h.hittini@gmail.com>
Subject: Ring parameter information
Date: Mon, 15 Sep 2014 10:14:10 +0400
Message-ID: <F225A4E9-1298-4262-8F24-9BF368100C78@gmail.com>
References: <06FE00B9-3F10-48CD-ABC7-7817006FDBDD@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:65384 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867AbaIOGOO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 02:14:14 -0400
Received: by mail-wi0-f175.google.com with SMTP id cc10so3491989wib.2
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2014 23:14:13 -0700 (PDT)
Received: from [192.168.1.99] ([178.250.250.71])
        by mx.google.com with ESMTPSA id i6sm10514317wib.7.2014.09.14.23.14.12
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 14 Sep 2014 23:14:12 -0700 (PDT)
In-Reply-To: <06FE00B9-3F10-48CD-ABC7-7817006FDBDD@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have two network interfaces and I used "ethtool -g" to get their ring=
 parameters, but I don=92t quite understand the output
=46or the ethernet interface the output says the operation is not suppo=
rted
=46or the wireless interface the output says the sending and receiving =
buffer sizes are equal to zero
I wonder if anyone can help me with that

hosam@Robin-01:~$ sudo ethtool -g eth0
Ring parameters for eth0:
Cannot get device ring settings: Operation not supported

hosam@Robin-01:~$ sudo ethtool -g wlan1
Ring parameters for wlan1:
Pre-set maximums:
RX:			0
RX Mini:		0
RX Jumbo:	0
TX:			0
Current hardware settings:
RX:			0
RX Mini:		0
RX Jumbo:	0
TX:			0

Regards,
Eng. Hosam Hittini