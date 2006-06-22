From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 3/7] NetLabel: CIPSOv4 engine
Date: Thu, 22 Jun 2006 02:12:23 -0700 (PDT)
Message-ID: <20060622.021223.125894633.davem@davemloft.net>
References: <20060621194234.979661000@flek.zko.hp.com>
	<20060621200031.589235000@flek.zko.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: redhat-lspp@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	sds@epoch.ncsc.mil, jmorris@redhat.com, sgrubb@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
To: paul.moore@hp.com
In-Reply-To: <20060621200031.589235000@flek.zko.hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: paul.moore@hp.com
Date: Wed, 21 Jun 2006 15:42:38 -0400

> Add support for the Commercial IP Security Option (CIPSO) to the
> IPv4 network stack.  CIPSO has become a de-facto standard for
> trusted/labeled networking amongst existing Trusted Operating
> Systems such as Trusted Solaris, HP-UX CMW, etc.  This
> implementation is designed to be used with the NetLabel subsystem to
> provide explicit packet labeling to LSM developers.

The thing that concerns me most about CIPSO is that even once users
migrate to a more SELINUX native approach from this CIPSO stuff, the
CIPSO code, it's bloat, and it's maintainence burdon will remain.

It's easy to put stuff it, it's impossible to take stuff out even
once it's largely unused by even it's original target audience.

And that's what I see happening here.

This is why, to be perfectly honest with you, I'd much rather
something like this stay out-of-tree and people are strongly
encouraged to use the more native stuff under Linux.
