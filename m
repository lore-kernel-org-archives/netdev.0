From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH v6 10/10] test: IPC message queue copy feture test
Date: Mon, 15 Oct 2012 20:23:26 +0100
Message-ID: <19575.1350329006@warthog.procyon.org.uk>
References: <20121015160027.28348.35065.stgit@localhost.localdomain> <20121015155800.28348.23561.stgit@localhost.localdomain>
Cc: dhowells@redhat.com, akpm@linux-foundation.org,
	catalin.marinas@arm.com, will.deacon@arm.com,
	manfred@colorfullife.com, hughd@google.com, jmorris@namei.org,
	mtk.manpages@gmail.com, kosaki.motohiro@jp.fujitsu.com,
	paulmck@linux.vnet.ibm.com, sds@tycho.nsa.gov, devel@openvz.org,
	a.p.zijlstra@chello.nl, cmetcalf@tilera.com,
	linux-driver@qlogic.com, ron.mercer@qlogic.com,
	viro@zeniv.linux.org.uk, eparis@parisplace.org, tglx@linutronix.de,
	jitendra.kalsaria@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, ebiederm@xmission.com,
	casey@schaufler-ca.com
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20121015160027.28348.35065.stgit@localhost.localdomain>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> +CFLAGS += -I../../../../arch/x86/include/generated/
> +CFLAGS += -I../../../../include/
> +CFLAGS += -I../../../../usr/include/
> +CFLAGS += -I../../../../arch/x86/include/

Do you need to add uapi/ into some of these?

David
