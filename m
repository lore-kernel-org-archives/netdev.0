From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux-next: zillions of lockdep whinges in include/net/sock.h:1408
Date: Thu, 21 Apr 2016 09:42:12 +0200
Message-ID: <1461224532.4101068.585250481.7A43E285@webmail.messagingengine.com>
References: <66816.1461198639@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <66816.1461198639@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Apr 21, 2016, at 02:30, Valdis Kletnieks wrote:
> linux-next 20160420 is whining at an incredible rate - in 20 minutes of
> uptime, I piled up some 41,000 hits from all over the place (cleaned up
> to skip the CPU and PID so the list isn't quite so long):

Thanks for the report. Can you give me some more details:

Is this an nfs socket? Do you by accident know if this socket went
through xs_reclassify_socket at any point? We do hold the appropriate
locks at that point but I fear that the lockdep reinitialization
confused lockdep.

Thanks,
Hannes
