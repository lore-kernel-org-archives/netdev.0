From: "Jan Beulich" <JBeulich@novell.com>
Subject: lost NETIF_F_GRO in cxgb3 during conversion to hw_features?
Date: Mon, 04 Jul 2011 10:19:44 +0100
Message-ID: <4E11A1D0020000780004BFA7@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "mirq-linux@rere.qmqm.pl" <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

prior to that change of yours, the flag was set unconditionally, while
now it can be set only through the ioctl. Is that really correct?

Thanks, Jan

