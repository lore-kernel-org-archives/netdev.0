From: Olaf Hering <olh@suse.de>
Subject: Re: [PATCH] compat bug in sys_recvmsg, MSG_CMSG_COMPAT check missing
Date: Sat, 5 Jun 2004 23:14:09 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040605211409.GC1134@suse.de>
References: <20040605204334.GA1134@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Olaf Hering <olh@suse.de>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262422AbUFEVOR@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040605204334.GA1134@suse.de>
List-Id: netdev.vger.kernel.org

 On Sat, Jun 05, Olaf Hering wrote:

>=20
> packet_recvmsg() gets the flags from the compat_sys_socketcall(), but=
 it
> does not check for the active MSG_CMSG_COMPAT bit. As a result, it
> returns -EINVAL and makes the user rather unhappy

possible related bugs are in:

ipx_sendmsg
pfkey_recvmsg
x25_sendmsg
ax25_sendmsg
irda_sendmsg
irda_sendmsg_dgram
irda_sendmsg_ultra
rose_sendmsg
atalk_sendmsg
dn_recvmsg
dn_sendmsg
econet_sendmsg
wanpipe_sendmsg
nr_sendmsg


--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
