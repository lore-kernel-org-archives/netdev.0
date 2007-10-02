From: "Kalle Pokki" <kalle.pokki@iki.fi>
Subject: Blackfin Ethernet MAC driver compile error
Date: Tue, 2 Oct 2007 14:30:42 +0300
Message-ID: <a425f86c0710020430o3507eeb2veb104dc936f230dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bryan.wu@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:1162 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbXJBLa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 07:30:58 -0400
Received: by an-out-0708.google.com with SMTP id d31so601500and
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2007 04:30:58 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Blackfin Ethernet MAC driver does not compile. It seems the driver is
missing some pinmux defines.

  CC      drivers/net/bfin_mac.o
drivers/net/bfin_mac.c: In function 'setup_pin_mux':
drivers/net/bfin_mac.c:275: error: 'P_MII0' undeclared (first use in
this function)
drivers/net/bfin_mac.c:275: error: (Each undeclared identifier is
reported only once
drivers/net/bfin_mac.c:275: error: for each function it appears in.)
drivers/net/bfin_mac.c:279: error: implicit declaration of function
'peripheral_request_list'
drivers/net/bfin_mac.c:285: error: implicit declaration of function
'peripheral_free_list'
make[2]: *** [drivers/net/bfin_mac.o] Error 1
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2
