From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [2.6 patch] net/lapb/lapb_iface.c: remove unused code
Date: Wed, 15 Dec 2004 23:58:22 +0000
Message-ID: <1103155101.3585.26.camel@localhost.localdomain>
References: <20041215010745.GB12937@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jonathan Naylor <g4klx@g4klx.demon.co.uk>, netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041215010745.GB12937@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mer, 2004-12-15 at 01:07, Adrian Bunk wrote:
> The patch below removes the following unused code:
> - EXPORT_SYMBOL'ed functions lapb_getparms and lapb_setparms
> - struct lapb_parms_struct
> 
> Please review whether it's correct or conflicts with pending changes.

Please keep these, they are used by out of kernel code and they are also
required in order to run test sets on the full code functionality.
