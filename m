From: Steve Hill <steve@navaho.co.uk>
Subject: Re: [PATCH] fix netfilter refcounting [was Re: Conntrack leak
 (2.6.2rc2)]
Date: Wed, 4 Feb 2004 10:19:45 +0000 (GMT)
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <Pine.LNX.4.58.0402041018120.15629@sorbus2.navaho>
References: <Pine.LNX.4.33.0402031825170.11950-100000@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
In-Reply-To: <Pine.LNX.4.33.0402031825170.11950-100000@blackhole.kfki.hu>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Tue, 3 Feb 2004, Jozsef Kadlecsik wrote:

> Steve Hill reported a conntrack leakage in 2.6.2-rc2 when nat is enabled
> and the system forwards fragmented packets. It turned out that an
> nf_conntrack_put was missing from ip_copy_metadata:

I noticed this fix made it into the 2.6.2 release last night, so I have 
tested with a vanilla 2.6.2 kernel this morning and can confirm it's fixed 
the problem.  Thank you.

- Steve Hill
Senior Software Developer                        Email: steve@navaho.co.uk
Navaho Technologies Ltd.                           Tel: +44-870-7034015

        ... Alcohol and calculus don't mix - Don't drink and derive! ...
