From: Srihari Vijayaraghavan <harisri@bigpond.com>
Subject: Re: [update] 2.6.2-rc1 - Realtek 8169 patches
Date: Sun, 25 Jan 2004 13:06:58 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251306.58563.harisri@bigpond.com>
References: <20040122234725.A8109@electric-eye.fr.zoreil.com> <200401241522.18369.harisri@bigpond.com> <20040124111601.A30087@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040124111601.A30087@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Romieu,

On Saturday 24 January 2004 21:16, you wrote:
> > I have applied your patches (all of them) and the kernel oops when I ping
> > to that machine from a remote machine :-(.
>
> Ok, can you publish/send me offlist an objdump -S of your r8169 module +
> r8169.c source ?

Please read my comments below and tell me if you still want the objdump?

> > I will try to track down which one of your patch introduces the
> > regression.
>
> Thanks, a binary search can be done in 5~6 different rounds.

Oh yes, been there done that :-). The r8169-addr-high.patch introduces the 
regression. The good news is that the previous 13 patches do not introduce 
any issues, and the kernel is stable with them.

Thanks
Hari
