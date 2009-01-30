From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] netfilter: unfold two critical loops in ip_packet_match()
Date: Fri, 30 Jan 2009 18:50:21 +0100
Message-ID: <20090130175021.GC18453@one.firstfloor.org>
References: <497F5F86.9010101@hp.com> <498063E7.5030106@cosmosbay.com> <49808708.3050502@trash.net> <498090C1.5020400@cosmosbay.com> <49809716.3020204@cosmosbay.com> <4981CBE2.5020306@cosmosbay.com> <87ocxox0bu.fsf@basil.nowhere.org> <498330B2.4060004@cosmosbay.com> <20090130172705.GB18453@one.firstfloor.org> <49833889.4000201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49833889.4000201@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So... you suggest me to split file, and use a "-funroll-loops",
> that might doing strange things on some arches / compilers...

I don't think it will. -funroll-loops is pretty clear defined.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
