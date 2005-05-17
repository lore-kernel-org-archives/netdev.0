From: John Heffner <jheffner@psc.edu>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 16:29:08 -0400
Message-ID: <200505171629.08943.jheffner@psc.edu>
References: <OF0221F508.AD091D99-ON88257004.006D0C52-88257004.006D8293@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, akepner@sgi.com,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF0221F508.AD091D99-ON88257004.006D0C52-88257004.006D8293@us.ibm.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 17 May 2005 03:56 pm, David Stevens wrote:
> Dave,
>         Shouldn't that be an estimator on the destination RTT? Or is that

Unfortunately, it's not the RTT that matters, but link speed.
You could probably do some heuristics on this, but I don't know if it's worth 
the effort.

IMO, high-rate applications which rely on IP fragmentation and a 16-bit ones 
complement for data integrity are broken, and a band-aid style workaround for 
them is probably good enough.  As long as it's not inflicted on the rest of 
us. :)

  -John
