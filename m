From: Hemant-vilas RAMDASI <hemant.ramdasi@stericsson.com>
Subject: about tx_queue_len for phonet driver
Date: Thu, 12 Jan 2012 11:45:48 +0100
Message-ID: <81C3A93C17462B4BBD7E272753C105791FB10F9968@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?iso-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:56983 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753300Ab2ALKqN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jan 2012 05:46:13 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Can anyone guide me about when should a network driver set tx_queue_len to 0?
We are facing a network congestion issue with phonet packets where one of the control message packet is dropped because of congestion. In our phonet network driver the tx_queue_len is set to 3 (taken from usb-phonet mostly). If phonet cannot handle packet-drop (for pipe messages), then should network driver always set tx_queue_len as 0?

Regards,
Hemant
