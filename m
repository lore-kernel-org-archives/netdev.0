From: David Miller <davem@davemloft.net>
Subject: Re: net: socket: NULL ptr deref in sendmsg
Date: Mon, 14 Jul 2014 15:08:47 -0700 (PDT)
Message-ID: <20140714.150847.1399242734159771901.davem@davemloft.net>
References: <53C2FF3D.4030201@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, a.ryabinin@samsung.com
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53C2FF3D.4030201@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Sun, 13 Jul 2014 17:50:53 -0400

> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel with the KASAN patchset, I've stumbled on the following spew:
 ...
> It's similar to another variation:
 ...
> I've tried debugging it, but I don't see a code path that could lead to that.

Both of these cases involve working with pointers declared with
DECLARE_SOCKADDR, maybe that somehow confuses ASAN code generation?
