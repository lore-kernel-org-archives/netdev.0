From: Florian Weimer <fweimer@bfk.de>
Subject: Re: [PATCH 2.6.18-rc6 1/2] dllink driver: porting v1.19 to linux 2.6.18-rc6
Date: Thu, 21 Sep 2006 15:29:09 +0200
Message-ID: <82slilmjq2.fsf@mid.bfk.de>
References: <1157620189.2904.16.camel@localhost.localdomain>
	<1157620795.14882.16.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hayim Shaul <hayim@iportent.com>, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org, edward_peng@dlink.com.tw,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751070AbWIUN3c@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1157620795.14882.16.camel@laptopd505.fenrus.org> (Arjan van de Ven's message of "Thu, 07 Sep 2006 11:19:55 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Arjan van de Ven:

>>  	if (irq)
>>  		spin_lock(&np->tx_lock);
>>  	else
>>  		spin_lock_irqsave(&np->tx_lock, flag);
>
> double eeeep
>
> this is wrong to do with in_interrupt() as gating factor!

Well, this is not Hayim fault.  It's in 2.6.18 as is.

Unfortunately, the driver does not work very well.  Transmitting
frames hangs after a while (quickly to reproduce with ping -f
-s40000).  Any suggestions how we could this get working?  The cards
used work quite well in older systems despite all the driver bugs, but
current systems with different timings expose them.

-- 
Florian Weimer                <fweimer@bfk.de>
BFK edv-consulting GmbH       http://www.bfk.de/
Durlacher Allee 47            tel: +49-721-96201-1
D-76131 Karlsruhe             fax: +49-721-96201-99
