From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Compile Error with r8169.c
Date: Sat, 24 Jan 2004 21:40:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124214009.A2069@electric-eye.fr.zoreil.com>
References: <Pine.LNX.4.58.0401241222570.19565@duron.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Lameter <christoph@graphe.net>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0401241222570.19565@duron.home>; from christoph@graphe.net on Sat, Jan 24, 2004 at 12:25:54PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Lameter <christoph@graphe.net> :
> Could you provide a diff against the current kernel? I applied all the

Yes, just tell me what your current is. :o)

(side note: if you do not send it now, you will have to wait until tomorrow
evening as saturday evening is getting closer)

Send your .config (off-list) if you think there is something wrong so that
I can reproduce the problem. I have tested that the patches apply fine and
compile modular against plain 2.4.2-rc1.

[...]
> My main problem with the existing driver is that the driver will hang when
                           ^^^^^^^^ -> which kernel ? (un)patched ?
> I insmod it on my duron system with a VIA mainboard (KLE133). Only the
> insmod hangs. I can still login to other sessions and the system operates
> normally apart from the hanging process in D state.

You can try the first 10 patches (i.e. including r8169-intr_mask.patch)
from the last serie.

--
Ueimor
