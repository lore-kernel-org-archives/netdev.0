From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: strange network performance degradation 2.6.8-rc3-mm1 -> 2.6.8-rc4-mm1
Date: Sat, 14 Aug 2004 17:08:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814150824.GA21843@electric-eye.fr.zoreil.com>
References: <20040814060948.GA7842@middle.of.nowhere> <20040814121533.GB18754@electric-eye.fr.zoreil.com> <20040814135606.GA6001@middle.of.nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jurriaan <thunder7@xs4all.nl>
Content-Disposition: inline
In-Reply-To: <20040814135606.GA6001@middle.of.nowhere>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jurriaan <thunder7@xs4all.nl> :
[...]
> > 1 - try the "pci=routeirq" argument at startup on your 2.6.8-rc4-mm1 if you
> >     have not done so;
> 
> that didn't help

Ok. Bad day.

[...]
> > 2 - apply to your 2.6.8-rc4-mm1 tree:
> >     http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-mm-revert.patch
> 
> I don't get it.
[...]
> This patch fails both with and without -R - how am I supposed to apply
> it?

Without -R.

[linux-2.6.8-rc4-mm1]$ patch -p1 --dry-run < /tmp/8139too-mm-revert.patch
patching file drivers/net/8139too.c
[linux-2.6.8-rc4-mm1]$ md5sum drivers/net/8139too.c
70b78e69d4c2387b63aaee943e67a244  drivers/net/8139too.c

Can you check the md5sum of the 8139too.c file in your 2.6.8-rc4-mm1 tree ?

--
Ueimor
