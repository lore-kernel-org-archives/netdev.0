From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Compile Error with r8169.c
Date: Sat, 24 Jan 2004 23:09:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124230914.C2069@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.58.0401241222570.19565@duron.home> <20040124214009.A2069@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0401241248050.19622@duron.home> <20040124222128.B2069@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0401241335440.19956@duron.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@lameter.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0401241335440.19956@duron.home>; from christoph@lameter.com on Sat, Jan 24, 2004 at 01:41:41PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@lameter.com> :
[...]
> Ok. so this is the issue. The result of my patching is attached. I
> followed the instructions from the README.txt.

/me checks... 

The README.txt looks like my "series" file:
[...]
14:a:r8169-tx-index-overflow
15:a:r8169-dma-api-tx
16:a:r8169-dma-api-rx-buffers
17:a:r8169-dma-api-tx-buffers
18:a:r8169-rx_copybreak
19:a:r8169-mac-phy-version
20:a:r8169-init_one
21:a:r8169-timer
22:a:r8169-hw_start
23:a:r8169-intr_mask
24:a:r8169-suspend
25:a:r8169-endianness
26:a:r8169-getstats
27:a:r8169-addr-high
28:a:r8169-ethtool-introduction
29:a:r8169-missing-static

(I will look your file tomorrow -> going offline for today)

> Could you just make the patched file available or a combined diff? I could
> have made a mistake by patching it but re-doing all the steps does not
> give me any hint what I did wrong.

http://www.fr.zoreil.com/people/francois/misc/r8169.c-intr-mask
http://www.fr.zoreil.com/people/francois/misc/r8169.c-missing-static

--
Ueimor
