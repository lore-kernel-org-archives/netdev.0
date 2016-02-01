From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/4] netfilter: ipv4: use preferred kernel types
Date: Mon, 1 Feb 2016 16:37:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD2580@AcuExch.aculab.com>
References: <1454159878-20706-1-git-send-email-tanure@linux.com>
 <1454159878-20706-3-git-send-email-tanure@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Lucas Tanure' <tanure@linux.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454159878-20706-3-git-send-email-tanure@linux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lucas Tanure
> Sent: 30 January 2016 13:18
> As suggested by checkpatch.pl:
> CHECK: Prefer kernel type 'uX' over 'uintX_t'

One might ask why?
The kernel types are older, but the uintX_t ones are now part
of the C standard.

Writing header files (eg for ioctl buffers) that have to be
parsed by both userspace and kernel is a PITA unless the uintX_t
forms are used - at which point you have inconsistent names
in the same file.

At some point someone might decide that the uintX_t types are
preferred (as NetBSD did a few years ago) - so these changes
would get reverted.

	David
