From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: [Fwd: kernel 2.4.21]
Date: 19 Jul 2003 18:05:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058634345.22000.2.camel@dhcp22.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----Forwarded Message-----

> From: Cedric Gavage <cedric.gavage@unixtech.be>
> To: linux-kernel@vger.kernel.org
> Subject: kernel 2.4.21
> Date: 19 Jul 2003 16:38:11 +0200
> 
> Hi all,
> 
> I have a little question...
> 
> 
> Summary of changes from v2.4.21-pre4 to v2.4.21-pre5
> ============================================
> 
> Alan Cox <alan@lxorguk.ukuu.org.uk>:
>    o ACPI apparently wasnt bios
>    o fix wrong date in microcode comment
>    o add another legitimate P4 type
>    o must disallow write combine on 450NX
>    o add framework for ndelay (nanoseconds)
>    o first block of parisc resend
>    o second block of parisc merge
>    o third block of parisc merge
>    o Ian Nelson moved
>    o update videobook docs to avoid check_region
>    o docs for IPMI
>    o remove dead init call
>    o add AMD hammer rng
>    o IPMI driver updates
>    o keyboard changes
>    o fix wrong test in raw driver
>    o fix paths for ide
>    o clarify hpt37x config
>    o fix more ide paths
>    o Paul's fix to do ide_cs handling in task context
>    o more ide paths
>    o fix use of check_region in umc driver
>    o more ide comment/doc info updates
>    o promise printk cleanups
>    o another wrong path
>    o IDE printk/cleanup bits
>    o fix padding on eepro driver
> 
> In this patch, is it possible that there is a problem in the fix of 
> eepro driver? Since I upgrade the kernel with 2.4.20-8 (kernel-source 
> tag in debian) which include this patch I have some problem with packets 
> which are sometimes truncated... (the server runs an ircd and the result 
> is a delink).
> 
> Jul 17 06:31:00 fazer kernel: KERNEL: assertion (newsk->state != 
> TCP_SYN_RECV) failed at tcp.c(2229)
> Jul 17 06:31:00 fazer kernel: KERNEL: assertion 
> ((1<<sk2->state)&(TCPF_ESTABLISHED|TCPF_CLOSE_WAIT|TCPF_CLOSE)) failed a
> t af_inet.c(689)
> Jul 17 18:27:53 fazer kernel: KERNEL: assertion (newsk->state != 
> TCP_SYN_RECV) failed at tcp.c(2229)
> Jul 17 18:27:53 fazer kernel: KERNEL: assertion 
> ((1<<sk2->state)&(TCPF_ESTABLISHED|TCPF_CLOSE_WAIT|TCPF_CLOSE)) failed a
> t af_inet.c(689)
> Jul 17 20:52:35 fazer kernel: KERNEL: assertion (newsk->state != 
> TCP_SYN_RECV) failed at tcp.c(2229)
> Jul 17 20:52:35 fazer kernel: KERNEL: assertion 
> ((1<<sk2->state)&(TCPF_ESTABLISHED|TCPF_CLOSE_WAIT|TCPF_CLOSE)) failed a
> t af_inet.c(689)
> Jul 17 21:52:16 fazer kernel: KERNEL: assertion (newsk->state != 
> TCP_SYN_RECV) failed at tcp.c(2229)
> Jul 17 21:52:16 fazer kernel: KERNEL: assertion 
> ((1<<sk2->state)&(TCPF_ESTABLISHED|TCPF_CLOSE_WAIT|TCPF_CLOSE)) failed a
> t af_inet.c(689)
> Jul 17 22:49:31 fazer kernel: KERNEL: assertion (newsk->state != 
> TCP_SYN_RECV) failed at tcp.c(2229)
> Jul 17 22:49:31 fazer kernel: KERNEL: assertion 
> ((1<<sk2->state)&(TCPF_ESTABLISHED|TCPF_CLOSE_WAIT|TCPF_CLOSE)) failed a
> t af_inet.c(689)
> 
> OR
> Jul 12 21:33:58 fazer kernel: recvmsg bug: copied DDDA9120 seq DDDA91E9
> Jul 12 21:33:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
> at tcp.c(1545)
> Jul 12 21:33:58 fazer kernel: recvmsg bug: copied DDDA9120 seq DDDA91E9
> Jul 12 21:33:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
> at tcp.c(1545)
> Jul 12 21:33:58 fazer kernel: recvmsg bug: copied DDDA9120 seq DDDA91E9
> Jul 12 21:33:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
> at tcp.c(1545)
> Jul 12 21:33:58 fazer kernel: recvmsg bug: copied DDDA9120 seq DDDA91E9
> Jul 12 21:33:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
> at tcp.c(1545)
> Jul 12 21:33:58 fazer kernel: recvmsg bug: copied DDDA9120 seq DDDA91E9
> Jul 12 21:33:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
> at tcp.c(1545)
> Jul 12 21:33:58 fazer kernel: recvmsg bug: copied DDDA9120 seq DDDA91E9
> Jul 12 21:33:59 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
> at tcp.c(1545)
> Jul 12 21:33:59 fazer kernel: recvmsg bug: copied DDDA9120 seq DDDA91E9
> Jul 12 21:33:59 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
> at tcp.c(1545)
> 
> 
> If I do a rollback, no more problems... I don't test yet a 2.4.21 kernel.
> 
> Hardware is a Dell PowerAppWeb 120A with one CPU P3 1 GHz / 256 Mo RAM /
> 
> Now Kernel is generated under debian with kernel-source-2.4.20-2 and gcc 
> version 2.95.4 20011002.
> 
> Any idea? (Thanks for your help)
> 
> -- 
>   Cedric Gavage <cedric.gavage@unixtech.be>
>   http://unixtech.be - http://gavage.com - OpenPGP: 0xED325C64
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
