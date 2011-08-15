From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: configurable sysctl parameter
 "net.core.tcp_lowat" for sk_stream_min_wspace()
Date: Sun, 14 Aug 2011 22:47:14 -0700 (PDT)
Message-ID: <20110814.224714.2061635645365376268.davem@davemloft.net>
References: <4E48B0C3.2010203@ctc-g.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, omega-g1@ctc-g.co.jp,
	notsuki@redhat.com, motokazu.kozaki@hp.com, htaira@redhat.com,
	netdev@vger.kernel.org, tomohiko.takahashi@ctc-g.co.jp,
	kotaro.sakai@ctc-g.co.jp, ken.sugawara@ctc-g.co.jp
To: jun.kondo@ctc-g.co.jp
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E48B0C3.2010203@ctc-g.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jun.Kondo" <jun.kondo@ctc-g.co.jp>
Date: Mon, 15 Aug 2011 14:38:11 +0900

> 2. to limit the block time of the write in order to
> prevent the timeout of upper layer applications
> even when the connection has low throughput, such
> as low rate streaming

Use non-blocking writes if you want this behavior.
