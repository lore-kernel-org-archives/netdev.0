From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Invalid sk_policy[] access
Date: Tue, 23 Feb 2016 15:53:29 -0500
Message-ID: <20160223205329.GD4941@oracle.com>
References: <20160222010201.GB23053@oracle.com>
 <20160223121244.GI28756@oracle.com>
 <alpine.LRH.2.20.1602232132190.30129@math.ut.ee>
 <20160223.152045.440181358695767083.davem@davemloft.net>
 <20160223202901.GC4941@oracle.com>
 <alpine.LRH.2.20.1602232250000.30129@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: mroos@linux.ee
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.20.1602232250000.30129@math.ut.ee>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (02/23/16 22:51), mroos@linux.ee wrote:
> Since there are no config-dependent difference in the struct, maybe it's 
> a compiler version difference for padding/optimization instead?

possibly. The v440 is using  a Debian 4.6.3-14 gcc, while the
T5 is using "4.4.7 20120313 (Red Hat 4.4.7-4)"

But my question from the email remains. Unless I am missing
something subtle in the code, a  struct request_sock and a 
struct sock only have the sock_common part in common. So casting
a request_sock as a struct sock may have issues?

--Sowmini


