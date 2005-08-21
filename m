From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.12 Performance problems
Date: Sun, 21 Aug 2005 12:47:46 -0700
Message-ID: <20050821124746.5d57203f.akpm@osdl.org>
References: <20050821154654.63788.qmail@web33303.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751114AbVHUVPv@vger.kernel.org>
To: danial_thom@yahoo.com
In-Reply-To: <20050821154654.63788.qmail@web33303.mail.mud.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Danial Thom <danial_thom@yahoo.com> wrote:
>
> I just started fiddling with 2.6.12, and there
> seems to be a big drop-off in performance from
> 2.4.x in terms of networking on a uniprocessor
> system. Just bridging packets through the
> machine, 2.6.12 starts dropping packets at
> ~100Kpps, whereas 2.4.x doesn't start dropping
> until over 350Kpps on the same hardware (2.0Ghz
> Opteron with e1000 driver). This is pitiful
> prformance for this hardware. I've 
> increased the rx ring in the e1000 driver to 512
> with little change (interrupt moderation is set
> to 8000 Ints/second). Has "tuning" for MP 
> destroyed UP performance altogether, or is there
> some tuning parameter that could make a 4-fold
> difference? All debugging is off and there are 
> no messages on the console or in the error logs.
> The kernel is the standard kernel.org dowload
> config with SMP turned off and the intel ethernet
> card drivers as modules without any other
> changes, which is exactly the config for my 2.4
> kernels.
> 

(added netdev to cc)
