From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: RESEND, HTB(?) softlockup, vanilla 2.6.24
Date: Sat, 16 Feb 2008 12:25:31 +0200
Message-ID: <20080216102502.M41110@visp.net.lb>
References: <20080213081318.M90354@visp.net.lb> <47B69824.4030405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:55349 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbYBPKZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 05:25:43 -0500
In-Reply-To: <47B69824.4030405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks, i will try it.
You think lockdep can be buggy?

On Sat, 16 Feb 2008 09:00:36 +0100, Jarek Poplawski wrote
> Denys Fedoryshchenko wrote, On 02/13/2008 09:13 AM:
> 
> > It is very difficult to reproduce, happened after running about 1month. 
No 
> > changes done in classes at time of crash.
> > 
> > Kernel 2.6.24 vanilla
> 
> Hi,
> 
> I could be wrong, but IMHO this looks like stack was overridden here,
> so my proposal is to try this:
> 
> CONFIG_DEBUG_STACKOVERFLOW=y
> 
> But, if you're not very interested in reproducing this, you could 
> also try to turn off some other debugging, especially lockdep.
> 
> Regards,
> Jarek P.
> 
> ....
> 
> > Feb 10 15:53:22 SHAPER [ 8271.778915] BUG: NMI Watchdog detected LOCKUP
> > Feb 10 15:53:22 SHAPER on CPU1, eip c01f0e5d, registers:
> 
> ....
> 
> > Feb 10 15:53:22 SHAPER [ 8271.779307] Pid: 0, comm: swapper Not tainted 
> > (2.6.24-build-0021 #26)
> > Feb 10 15:53:22 SHAPER [ 8271.779327] EIP: 0060:[<c01f0e5d>] EFLAGS: 
00000082 
> > CPU: 1
> > Feb 10 15:53:22 SHAPER [ 8271.779349] EIP is at __rb_rotate_right+0x5/0x50
> > Feb 10 15:53:22 SHAPER [ 8271.779366] EAX: f76494a4 EBX: f76494a4 ECX: 
> > f76494a4 EDX: c1ff5f80
> > Feb 10 15:53:22 SHAPER [ 8271.779386] ESI: f76494a4 EDI: c1ff5f80 EBP: 
> > 00000000 ESP: f7c29c70
> > Feb 10 15:53:22 SHAPER [ 8271.779406]  DS: 007b ES: 007b FS: 00d8 GS: 
0000 
> > SS: 0068
> > Feb 10 15:53:22 SHAPER [ 8271.779425] Process swapper (pid: 0, 
ti=f7c28000 
> > task=f7c20a60 task.ti=f7c28000)
> > Feb 10 15:53:22 SHAPER
> > Feb 10 15:53:22 SHAPER [ 8271.779446] Stack:
> > Feb 10 15:53:22 SHAPER f76494a4
> > Feb 10 15:53:22 SHAPER f76494a4
> > Feb 10 15:53:22 SHAPER f76494a4
> > Feb 10 15:53:22 SHAPER c01f0ef4
> > Feb 10 15:53:22 SHAPER c1ff5f80
> > Feb 10 15:53:22 SHAPER f76494a4
> > Feb 10 15:53:22 SHAPER f76494a8
> > Feb 10 15:53:22 SHAPER c1ff5f78
> > Feb 10 15:53:22 SHAPER
> > Feb 10 15:53:22 SHAPER [ 8271.779493]
> > Feb 10 15:53:22 SHAPER [ 8271.779307] Pid: 0, comm: swapper Not tainted 
> > (2.6.24-build-0021 #26)
> > Feb 10 15:53:22 SHAPER [ 8271.779327] EIP: 0060:[<c01f0e5d>] EFLAGS: 
00000082 
> > CPU: 1
> > Feb 10 15:53:22 SHAPER [ 8271.779349] EIP is at __rb_rotate_right+0x5/0x50
> > Feb 10 15:53:22 SHAPER [ 8271.779366] EAX: f76494a4 EBX: f76494a4 ECX: 
> > f76494a4 EDX: c1ff5f80
> > Feb 10 15:53:22 SHAPER [ 8271.779386] ESI: f76494a4 EDI: c1ff5f80 EBP: 
> > 00000000 ESP: f7c29c70
> > Feb 10 15:53:22 SHAPER [ 8271.779406]  DS: 007b ES: 007b FS: 00d8 GS: 
0000 
> > SS: 0068
> > Feb 10 15:53:22 SHAPER [ 8271.779425] Process swapper (pid: 0, 
ti=f7c28000 
> > task=f7c20a60 task.ti=f7c28000)
> > Feb 10 15:53:22 SHAPER
> > Feb 10 15:53:22 SHAPER [ 8271.779446] Stack:
> > Feb 10 15:53:22 SHAPER f76494a4
> > Feb 10 15:53:22 SHAPER f76494a4
> > Feb 10 15:53:22 SHAPER f76494a4
> 
> ....
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

