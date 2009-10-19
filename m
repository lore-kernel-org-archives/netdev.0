From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] AF_UNIX: Fix deadlock on connecting to shutdown socket
Date: Mon, 19 Oct 2009 06:14:59 -0700 (PDT)
Message-ID: <20091019.061459.193694892.davem@davemloft.net>
References: <4ADC010C.5070809@hitachi.com>
	<20091019115713.GB6869@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomoki.sekiyama.qu@hitachi.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk,
	satoshi.oshima.fk@hitachi.com, hidehiro.kawai.ez@hitachi.com,
	hideo.aoki.tk@hitachi.com
To: jarkao2@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756144AbZJSNOi@vger.kernel.org>
In-Reply-To: <20091019115713.GB6869@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 19 Oct 2009 11:57:13 +0000

> Isn't the shutdown call expected to change sk_state to TCP_CLOSE?

No, because the send side is still up and operational, it's
only a half duplex close.
