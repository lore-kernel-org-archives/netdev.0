From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [Regression, 4.12-rc1] Address family not supported by protocol
Date: Fri, 9 Jun 2017 16:43:22 -0700
Message-ID: <10656c28-6789-41d8-dc2d-d1c84b6c2793@infradead.org>
References: <c882b399-e183-8113-32aa-757abcd269bd@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Paul Menzel <pmenzel@molgen.mpg.de>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:44752 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdFIXn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 19:43:29 -0400
In-Reply-To: <c882b399-e183-8113-32aa-757abcd269bd@molgen.mpg.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[adding netdev]

Hi Paul,
Did you get anywhere with this?

The only difference that I see in the kernel config files is

4.12-rc1 says:
# CONFIG_NET_SCH_DEFAULT is not set

and 4.11 does not have that kconfig option.


On 05/15/17 05:53, Paul Menzel wrote:
> Dear Linux folks,
> 
> 
> When building Linux 4.12-rc1 with the configuration from Linux 4.11, then many user space programs show the error `Address family not supported by protocol`.
> 
> Please find the configuration, and the Linux kernel messages attached.
> 
> [    5.383630] systemd[1]: Failed to insert module 'autofs4': No such file or directory
> [    5.383808] systemd[1]: Failed to insert module 'unix': No such file or directory
> [    5.600711] systemd[1]: systemd 231 running in system mode. (+PAM -AUDIT -SELINUX +IMA -APPARMOR +SMACK +SYSVINIT +UTMP -LIBCRYPTSETUP +GCRYPT +GNUTLS -ACL +XZ -LZ4 -SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
> [    5.601028] systemd[1]: Detected architecture x86-64.
> [    5.623700] systemd[1]: Set hostname to <keineahnung.molgen.mpg.de>.
> [    5.631835] systemd[1]: Failed to read AF_UNIX datagram queue length, ignoring: No such file or directory
> [    6.404973] systemd[1]: Failed to allocate notification socket: Address family not supported by protocol
> [    6.405441] systemd[1]: Failed to allocate cgroups agent socket: Address family not supported by protocol
> [    6.405817] systemd[1]: Failed to allocate private socket: Address family not supported by protocol
> [    6.406218] systemd[1]: socket() failed: Address family not supported by protocol
> [    6.406379] systemd[1]: Failed to fully start up daemon: Address family not supported by protocol
> [    6.515759] systemd[1]: Failed to listen on udev Control Socket.
> [    8.597362] systemd-udevd[283]: error getting socket: Address family not supported by protocol
> Any help, where to report this issue to, is welcome.
> 
> 
> Kind regards,
> 
> Paul


-- 
~Randy
