From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.32 regression, hard lock
Date: Mon, 7 Dec 2009 14:30:57 -0800
Message-ID: <20091207143057.53c6a362.akpm@linux-foundation.org>
References: <20091206141419.GA6195@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Richard Zidlicky <rz@linux-m68k.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965107AbZLGWbJ@vger.kernel.org>
In-Reply-To: <20091206141419.GA6195@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 6 Dec 2009 15:14:19 +0100
Richard Zidlicky <rz@linux-m68k.org> wrote:

> Hello,
> 
> first visible symptom is that ppp over UMTS connection "stops working", connection
> did not die. Trying to restart the connection fails and the related processes hang.
> 
> After that one after another everything stops working, "telinit 6" does not do its
> job and SysRQ sync-umount-reboot is logged in messages but has no visible effect.
> 
> Attaching messages and .config.
> 

I uploaded your dmesg output to
http://userweb.kernel.org/~akpm/stuff/messages.txt

I'm looking at those traces and am not able to develop a theory to
explain it :(

There's some libata implication at timestamp 13203.385345 but that
looks like it's just a fluke.


So I'm stumped, sorry.  Maybe someone else can think of a way to attack
this.


btw, why does your kernel say "To Be Filled By O.E.M." in the traces? 
The kernel.org kernel doesn't do that.  Is that kernel patched at all?

Thanks.
