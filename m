From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big
 network copies (page allocation failure)
Date: Wed, 11 Apr 2012 07:43:00 +0200
Message-ID: <1334122980.5300.2154.camel@edumazet-glaptop>
References: <20120409.143710.879746943062854492.davem@davemloft.net>
	 <4F83316F.20504@lwfinger.net> <1333998672.3007.245.camel@edumazet-glaptop>
	 <20120409.153452.1284163346306246866.davem@davemloft.net>
	 <1334030180.13293.98.camel@edumazet-glaptop>
	 <20120410051127.GA32048@merlins.org>
	 <1334038263.2907.1.camel@edumazet-glaptop>
	 <20120411052733.GA17352@merlins.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org,
	bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc MERLIN <marc-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120411052733.GA17352-xnduUnryOU1AfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-04-10 at 22:27 -0700, Marc MERLIN wrote:
> On Tue, Apr 10, 2012 at 08:11:03AM +0200, Eric Dumazet wrote:
> > Please try following patch, as it solved the problem for me (no more
> > order-1 allocations in tx path)
> 
> I applied our patch to 3.3.1 and cannot reproduce the problem anymore.
> 
> I'll leave a big wireless copy running overnight just in case, but I think
> you fixed it.
> 
> Thanks much,
> Marc

Thanks Marc for bringing this issue.

I have a lenovo T420s laptop and could debug the thing pretty fast.

I'll send two official patches.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
