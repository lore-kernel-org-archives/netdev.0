From: mroos@linux.ee
Subject: Re: Invalid sk_policy[] access
Date: Tue, 23 Feb 2016 22:37:13 +0200 (EET)
Message-ID: <alpine.LRH.2.20.1602232236080.30129@math.ut.ee>
References: <20160222010201.GB23053@oracle.com> <20160223121244.GI28756@oracle.com> <alpine.LRH.2.20.1602232132190.30129@math.ut.ee> <20160223.152045.440181358695767083.davem@davemloft.net> <20160223202901.GC4941@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20160223202901.GC4941@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Indeed, the kernel is 64-bit in both cases.
> > And the userland bit-arity has no relevance whatsoever for this bug.
> 
> hang on; The sizeof (and offsetof) values I listed were obtained either
> from /usr/bin/crash (on the T5) or from simple printk's of the structures
> in the case of the v440. And they *are* different, and the numbers
> match the values dumped on the console on pnaic. So isnt there actually
> a problem here?

There certianly seems to be a problem - that's how you ended up looking 
under that rock.

Maybe the offsets are different because of different kernel config?

-- 
Meelis Roos (mroos@linux.ee)
