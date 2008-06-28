From: David Miller <davem@davemloft.net>
Subject: Re: [git patches] net driver updates for .27
Date: Sat, 28 Jun 2008 01:39:05 -0700 (PDT)
Message-ID: <20080628.013905.146863178.davem@davemloft.net>
References: <20080627062556.GA1521@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50729
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751635AbYF1IjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2008 04:39:05 -0400
In-Reply-To: <20080627062556.GA1521@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 27 Jun 2008 02:25:56 -0400

> Please pull from 'davem-next' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-next

Please fix these new build failures and warnings then send me another
pull request :-)

drivers/net/wan/retina.c: In function 'fepci_stream_open':
drivers/net/wan/retina.c:930: warning: cast from pointer to integer of different size
drivers/net/wan/retina.c:930: warning: cast to pointer from integer of different size
drivers/net/wan/retina.c:933: warning: cast from pointer to integer of different size
drivers/net/wan/retina.c:933: warning: cast to pointer from integer of different size
drivers/net/wan/retina.c: In function 'fepci_stream_interrupt':
drivers/net/wan/retina.c:1129: error: 'struct fepci_ch_private' has no member named 'cur'
make[3]: *** [drivers/net/wan/retina.o] Error 1
make[2]: *** [drivers/net/wan] Error 2
make[2]: *** Waiting for unfinished jobs....

Thanks!
