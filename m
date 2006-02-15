From: Pekka J Enberg <penberg@cs.Helsinki.FI>
Subject: Re: [RFT/PATCH] 3c509: use proper suspend/resume API
Date: Wed, 15 Feb 2006 13:00:22 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0602151256580.14223@sbz-30.cs.Helsinki.FI>
References: <1139935173.22151.2.camel@localhost> <20060215022523.1d21b9c9.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751146AbWBOLAZ@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060215022523.1d21b9c9.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Feb 2006, Andrew Morton wrote:
> I have a 3c509, and I'm not afraid to use it!
> 
> Problem is, it doesn't resume correctly either with or without the patch:
> it needs rmmod+modprobe to get it going again.  (Which is better than the
> aic7xxx driver, which has a coronary and panics the kernel on post-resume
> reboot).

Is there anything in the logs to give us a clue what's going on? I can't 
see anything obvious looking at the code, but then again I don't have 
datasheets for 3c509 either.

			Pekka
