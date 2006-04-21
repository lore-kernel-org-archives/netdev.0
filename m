From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: Fw: [Bug 6421] New: kernel 2.6.10-2.6.16 on alpha: arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1) triggered
Date: Fri, 21 Apr 2006 19:45:36 +0200
Message-ID: <200604211945.37129.netdev@axxeo.de>
References: <20060421102757.45d26db0@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <p_gortmaker@yahoo.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tomri@gmx.net,
	Ingo Oeser <ioe-lkml@rameria.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932313AbWDURpw@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060421102757.45d26db0@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Looks like PIO at unaligned addresses doesn't work on alpha...

Maybe this should be fixed similiar to ioread32_rep in  arch/alpha/kernel/io.c?

This may slow it down, but will not break it.

> Begin forwarded message:
> 
> Date: Fri, 21 Apr 2006 02:35:45 -0700
> From: bugme-daemon@bugzilla.kernel.org
> To: shemminger@osdl.org
> Subject: [Bug 6421] New: kernel 2.6.10-2.6.16 on alpha: arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1) triggered

Regards

Ingo Oeser
