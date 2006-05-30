From: Jiri Slaby <jirislaby@gmail.com>
Subject: BUG: warning at ... (netlink) [Was: 2.6.17-rc5-mm1]
Date: Tue, 30 May 2006 13:01:27 +0159
Message-ID: <447C261E.1090202@gmail.com>
References: <20060530022925.8a67b613.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, alan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:10399 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932217AbWE3LBd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 May 2006 07:01:33 -0400
Received: by nf-out-0910.google.com with SMTP id x37so73306nfc
        for <netdev@vger.kernel.org>; Tue, 30 May 2006 04:01:31 -0700 (PDT)
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060530022925.8a67b613.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Andrew Morton napsal(a):
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.17-rc5/2.6.17-rc5-mm1/

BUG: warning at /l/latest/xxx/kernel/softirq.c:86/local_bh_disable()
 [<c0103e66>] show_trace+0x1b/0x1d
 [<c01045a4>] dump_stack+0x26/0x28
 [<c012708f>] local_bh_disable+0x53/0x55
 [<c0399fd6>] _write_lock_bh+0x10/0x15
 [<c034e314>] netlink_table_grab+0x12/0xe9
 [<c034e6f6>] netlink_insert+0x2a/0x156
 [<c034fa46>] netlink_kernel_create+0xad/0x143
 [<c051f869>] rtnetlink_init+0x70/0xc7
 [<c051fb9f>] netlink_proto_init+0x187/0x192
 [<c01003cb>] init+0x12b/0x2f1
 [<c0101005>] kernel_thread_helper+0x5/0xb

If more info needed, feel free to ask.

regards,
- --
Jiri Slaby         www.fi.muni.cz/~xslaby
\_.-^-._   jirislaby@gmail.com   _.-^-._/
B67499670407CE62ACC8 22A032CC55C339D47A7E
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFEfCYeMsxVwznUen4RApvNAJ94piY4mvFzO9x3qSBKL8DstkeBbgCguCnz
Zzw1YFf/s3AtKVo0XgYWsek=
=x+hX
-----END PGP SIGNATURE-----
