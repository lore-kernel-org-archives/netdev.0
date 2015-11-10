From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: Deadlock between bind and splice
Date: Tue, 10 Nov 2015 02:38:54 +0000
Message-ID: <20151110023854.GZ22011@ZenIV.linux.org.uk>
References: <CACT4Y+brDX=C15jSs33zGaCBt2BDPPzBcgqtKA2dYMdviYjKww@mail.gmail.com>
 <1446824535.4184.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Vyukov <dvyukov@google.com>, linux-fsdevel@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446824535.4184.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 06, 2015 at 07:42:15AM -0800, Eric Dumazet wrote:

> Thank you for this report.
> 
> pipe is part of fs, not net ;)

AF_UNIX bind() vs. socketpair() interplay, OTOH...
