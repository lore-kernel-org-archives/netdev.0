From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next 08/12] r8152: support TSO
Date: Tue, 04 Mar 2014 07:02:31 -0800
Message-ID: <1393945351.26794.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
	 <1393934464-23675-9-git-send-email-hayeswang@realtek.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6CFFE0@AcuExch.aculab.com>
	 <CF9EF717568D49DB858D5363B1099FC0@realtek.com.tw>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6D0284@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'hayeswang' <hayeswang@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nic_swsd@realtek.com" <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6D0284@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-03-04 at 14:35 +0000, David Laight wrote:

> Does that mean you are splitting the 64k 'ethernet packet' from TCP
> is software? I've looked at the ax88179 where the hardware can do it.
> 
> Is there really a gain doing segmentation here if you have to do the
> extra data copy?

There is no 'extra' copy.

There is _already_ a copy, so what's the deal of doing this copy in a SG
enabled way ?
