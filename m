From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: 2.6.23-rc5: possible irq lock inversion dependency detected
Date: Mon, 10 Sep 2007 14:03:33 +0200
Message-ID: <1189425813.21778.13.camel@twins>
References: <alpine.DEB.0.999.0709021455510.7103@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Christian Kujau <lists@nerdbynature.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932984AbXIJMFR@vger.kernel.org>
In-Reply-To: <alpine.DEB.0.999.0709021455510.7103@sheep.housecafe.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-09-02 at 15:11 +0200, Christian Kujau wrote:
> Hi,
> 
> after upgrading to 2.6.23-rc5 (and applying davem's fix [0]), lockdep 
> was quite noisy when I tried to shape my external (wireless) interface:
> 
> [ 6400.534545] FahCore_78.exe/3552 just changed the state of lock:
> [ 6400.534713]  (&dev->ingress_lock){-+..}, at: [<c038d595>] netif_receive_skb+0x2d5/0x3c0
> [ 6400.534941] but this lock took another, soft-read-irq-unsafe lock in the past:
> [ 6400.535145]  (police_lock){-.--}
> 
> This happened when I executed: http://nerdbynature.de/bits/2.6.23-rc5/qos.sh.txt
> (using iproute2-ss070313). The is still running, I just noticed a short 
> hickup, probably when it was busy writing the warning to the disk.
> 
> More details and .config: http://nerdbynature.de/bits/2.6.23-rc5/

seems unavailable at this time, please submit the whole lockdep report
if possible.
