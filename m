From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6] RTL8169 Suspend and Resume Stuff
Date: Mon, 1 Dec 2003 02:04:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201020453.A16405@electric-eye.fr.zoreil.com>
References: <1070212415.1607.17.camel@oxygenium>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brad House <brad@mcve.com>, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?iso-8859-1?Q?Fernando_Alencar_Mar=F3stica?= <famarost@unimep.br>
Content-Disposition: inline
In-Reply-To: <1070212415.1607.17.camel@oxygenium>; from famarost@unimep.br on Sun, Nov 30, 2003 at 03:13:35PM -0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have queued it with the following modifications (mostly to keep the style 
of the driver consistent):
- no whitespace before parenthesis for functions;
- s/ethernet_device/dev/ (like other drivers in drivers/net);
- write{b/w/l} -> RTL_W{8/16/32};
- netif_start_queue() done in rtl8169_hw_start().

See http://www.fr.zoreil.com/people/francois/misc/r8169/r8169-suspend.patch
for patch.

Btw, there is a flaw in r8169-dma-api-rx-buffers.patch so don't bother
testing it. I'll do it again tomorrow.

--
Ueimor
