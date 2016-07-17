From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: nb8800: Fix SKB leak in nb8800_receive()
Date: Sat, 16 Jul 2016 22:06:23 -0700 (PDT)
Message-ID: <20160716.220623.411789986162601008.davem@davemloft.net>
References: <1468626084-31618-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mans@mansr.com, sf84@laposte.net,
	arnd@arndb.de, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468626084-31618-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 15 Jul 2016 16:41:16 -0700

> In case nb8800_receive() fails to allocate a fragment, we would leak the
> SKB freshly allocated and just return, instead, free it.
> 
> Reported-by: coverity (CID 1341750)
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
