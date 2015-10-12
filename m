From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Use-after-free in ep_remove_wait_queue
Date: Mon, 12 Oct 2015 05:14:31 -0700
Message-ID: <1444652071.27760.156.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+b3xsLsKVFCz2M7nqqfXnyuMHEVYtJS2wN4WHLWs9A5ng@mail.gmail.com>
	 <20151012120249.GB16370@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Vyukov <dvyukov@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	dhowells@redhat.com, paul@paul-moore.com, salyzyn@android.com,
	sds@tycho.nsa.gov, ying.xue@windriver.com, netdev@vger.kernel.org,
	syzkaller@googlegroups.com, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Julien Tinnes <jln@google.com>,
	Kees Cook <keescook@google.com>,
	Mathias Krause <minipli@googlemail.com>,
	Jason Baron <jbaron@akamai.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20151012120249.GB16370@unicorn.suse.cz>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-10-12 at 14:02 +0200, Michal Kubecek wrote:

> Probably the issue discussed in
> 
>   http://thread.gmane.org/gmane.linux.kernel/2057497/
> 
> and previous related threads.
> 

Same issue, but Dmitry apparently did not trust me.


