From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: strange network performance degradation 2.6.8-rc3-mm1 -> 2.6.8-rc4-mm1
Date: Sat, 14 Aug 2004 19:28:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814172835.GA23427@electric-eye.fr.zoreil.com>
References: <20040814060948.GA7842@middle.of.nowhere> <20040814121533.GB18754@electric-eye.fr.zoreil.com> <20040814135606.GA6001@middle.of.nowhere> <20040814150824.GA21843@electric-eye.fr.zoreil.com> <20040814161039.GA1985@middle.of.nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jurriaan <thunder7@xs4all.nl>
Content-Disposition: inline
In-Reply-To: <20040814161039.GA1985@middle.of.nowhere>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jurriaan <thunder7@xs4all.nl> :
[...]
> Never mind, it seems my patch was saved incorrectly. Anyway, after
> applying this patch my network-traffic is as fast as it ever was.
> 
> There's no difference in dmesg-output, but I reach 450-460 KiB/s again.

Ok. So Jeff was right (TM).

> If there's anything else I can test, please let me know - I gather the
> update did work for other people, so if testers are wanted I'm
> available.

Can you apply 8139too-10.patch + 8139too-20.patch on top of your working
config (namely 2.6.8-rc4-mm1 + 8139too-mm-revert.patch) and tell if things
go wrong ?

--
Ueimor
