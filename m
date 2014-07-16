From: Christoph Schulz <develop@kristov.de>
Subject: Re: [PATCH net-next 1/1] net: ppp: reset nextseq counter when
 enabling SC_MULTILINK
Date: Wed, 16 Jul 2014 23:19:50 +0200
Message-ID: <20140716231950.17744ie9e3i9ea9i@berry.schulz.ip-v6.eu>
References: <53C4F987.1040401@kristov.de>
 <20140715.225259.1933230941203001162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server721-han.de-nserver.de ([85.158.180.102]:51002 "EHLO
	server721-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753349AbaGPVTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 17:19:54 -0400
In-Reply-To: <20140715.225259.1933230941203001162.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

David Miller schrieb am Tue, 15 Jul 2014 22:52:59 -0700 (PDT):

> Applied, thanks Christoph.

Sorry, the extra code has to be surrounded by

#ifdef CONFIG_PPP_MULTILINK
...
#endif

I will submit an updated patch ASAP.


Best regards,

Christoph Schulz
