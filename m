From: Olaf Hering <olh@suse.de>
Subject: Re: [PATCH] compat bug in sys_recvmsg, MSG_CMSG_COMPAT check missing
Date: Sat, 5 Jun 2004 23:17:01 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040605211701.GD1134@suse.de>
References: <20040605204334.GA1134@suse.de> <20040605140153.6c5945a0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S262451AbUFEVRO@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040605140153.6c5945a0.davem@redhat.com>
List-Id: netdev.vger.kernel.org

 On Sat, Jun 05, David S. Miller wrote:

> I can't see a reason, can anyone else?  If there is no reason, the
> right fix is simply to mask it out at the top level, for both
> sendmsg and recvmsg.

I did it first this way, but the result was a long delay until the dhcp
server replied, the patch sent earlier leads to a fast reply.

    err =3D sock_recvmsg(sock, &msg_sys, total_len, flags & ~MSG_CMSG_C=
OMPAT);
=20

--=20
USB is for mice, FireWire is for men!

sUse lINUX ag, n=C3=9CRNBERG
