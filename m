From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.12-rc6-mm1 OOPS in tcp_push_one()
Date: Wed, 08 Jun 2005 22:58:17 -0700 (PDT)
Message-ID: <20050608.225817.112619139.davem@davemloft.net>
References: <200506090423.j594NWts004829@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262278AbVFIF6W@vger.kernel.org>
To: Valdis.Kletnieks@vt.edu
In-Reply-To: <200506090423.j594NWts004829@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valdis.Kletnieks@vt.edu
Date: Thu, 09 Jun 2005 00:23:32 -0400

> (On a related note, how did tcp_bic get loaded? I requested all the new
> congestion stuff be built as modules, didn't specifically request any of
> them to actually be loaded....

It's the default algorithm, so when you open the first TCP
socket it tries to load it.
