From: Andrew Morton <akpm@digeo.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Tue, 17 Sep 2002 19:16:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D87E1F9.33909AC8@digeo.com>
References: <Pine.GSO.4.30.0209172053360.3686-100000@shell.cyberus.ca> <20020917.180014.07882539.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, manfred@colorfullife.com, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
>    From: jamal <hadi@cyberus.ca>
>    Date: Tue, 17 Sep 2002 20:57:58 -0400 (EDT)
> 
>    I am not so sure with that 6% difference there is no other bug lurking
>    there; 6% seems too large for an extra two PCI transactions per packet.
> 
> {in,out}{b,w,l}() operations have a fixed timing, therefore his
> results doesn't sound that far off.
> 
> It is also one of the reasons I suspect Andrew saw such bad results
> with 3c59x, but probably that is not the only reason.

They weren't "very bad", iirc.  Maybe a 5% increase in CPU load.

It was all a long time ago.  Will retest if someone sends URLs.
