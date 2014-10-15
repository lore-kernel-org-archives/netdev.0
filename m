From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: use hardware buffer pool to allocate skb
Date: Wed, 15 Oct 2014 08:57:52 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9D747B@AcuExch.aculab.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: 'Pan Jiafei' <Jiafei.Pan@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pan Jiafei
> In some platform, there are some hardware block provided
> to manage buffers to improve performance. So in some case,
> it is expected that the packets received by some generic
> NIC should be put into such hardware managed buffers
> directly, so that such buffer can be released by hardware
> or by driver.

This looks like some strange variant of 'buffer loaning'.
In general it just doesn't work due to the limited number
of such buffers - they soon all become queued waiting for
applications to read from sockets.

It also isn't at all clear how you expect a 'generic NIC'
to actually allocate buffers from your 'special area'.

	David



