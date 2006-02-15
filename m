From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFT/PATCH] 3c509: use proper suspend/resume API
Date: Wed, 15 Feb 2006 04:45:10 -0800
Message-ID: <20060215044510.5b416604.akpm@osdl.org>
References: <1139935173.22151.2.camel@localhost>
	<20060215022523.1d21b9c9.akpm@osdl.org>
	<Pine.LNX.4.58.0602151317110.14223@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1945927AbWBOMqR@vger.kernel.org>
To: Pekka J Enberg <penberg@cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.58.0602151317110.14223@sbz-30.cs.Helsinki.FI>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka J Enberg <penberg@cs.Helsinki.FI> wrote:
>
>  Hi Andrew,
> 
>  On Wed, 15 Feb 2006, Andrew Morton wrote:
>  > Problem is, it doesn't resume correctly either with or without the patch:
>  > it needs rmmod+modprobe to get it going again.  (Which is better than the
>  > aic7xxx driver, which has a coronary and panics the kernel on post-resume
>  > reboot).
> 
>  Hmm. Either I am totally confused or we don't even attempt suspend/resume 
>  for eisa and mca bus devices. Care to try this patch?

No, el3_suspend() and el3_resume() don't seem to be called.  And they're
still not called with this patch applied..

(I got one resume in which the 3c509 still worked.  Odd.)
