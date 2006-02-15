From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFT/PATCH] 3c509: use proper suspend/resume API
Date: Wed, 15 Feb 2006 03:52:51 -0800
Message-ID: <20060215035251.624a7273.akpm@osdl.org>
References: <1139935173.22151.2.camel@localhost>
	<20060215022523.1d21b9c9.akpm@osdl.org>
	<Pine.LNX.4.58.0602151256580.14223@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751154AbWBOLx6@vger.kernel.org>
To: Pekka J Enberg <penberg@cs.Helsinki.FI>
In-Reply-To: <Pine.LNX.4.58.0602151256580.14223@sbz-30.cs.Helsinki.FI>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka J Enberg <penberg@cs.Helsinki.FI> wrote:
>
> On Wed, 15 Feb 2006, Andrew Morton wrote:
> > I have a 3c509, and I'm not afraid to use it!
> > 
> > Problem is, it doesn't resume correctly either with or without the patch:
> > it needs rmmod+modprobe to get it going again.  (Which is better than the
> > aic7xxx driver, which has a coronary and panics the kernel on post-resume
> > reboot).
> 
> Is there anything in the logs to give us a clue what's going on? I can't 
> see anything obvious looking at the code, but then again I don't have 
> datasheets for 3c509 either.
> 

eeprom reads 0xffff, that's all I noticed.
