From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: ti: netcp: restore get/set_pad_info() functionality
Date: Tue, 9 Feb 2016 16:10:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCDC14B@AcuExch.aculab.com>
References: <1455026303-17014-1-git-send-email-grygorii.strashko@ti.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCDBFCC@AcuExch.aculab.com>
 <3E54258959B69E4282D79E01AB1F32B704D12AF4@DFLE11.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Cooper Jr., Franklin" <fcooper@ti.com>,
	"Nori, Sekhar" <nsekhar@ti.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>
To: "'Karicheri, Muralidharan'" <m-karicheri2@ti.com>,
	"Strashko, Grygorii" <grygorii.strashko@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	"Arnd Bergmann" <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3E54258959B69E4282D79E01AB1F32B704D12AF4@DFLE11.ent.ti.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Karicheri, Muralidharan
> Sent: 09 February 2016 16:10
...
> >In reality the 'pad' fields ought to be renamed - since they aren't pads.
> >Perhaps they should be a union?

> No. At the end of the descriptor, host software can add scratchpad which is
> not modified by the hardware, but is used by the driver. So please don't
> rename.

So comment in the definition that the hardware doesn't modify them.
The driver is defining these fields and they are definitely NOT padding.

	David
