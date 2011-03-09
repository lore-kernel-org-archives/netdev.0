From: Andrew Theurer <habanero@linux.vnet.ibm.com>
Subject: Re: Network performance with small packets
Date: Tue, 08 Mar 2011 20:21:18 -0600
Message-ID: <1299637278.13202.61.camel@localhost.localdomain>
References: <20110127.130240.104065182.davem@davemloft.net>
	 <OF5CFD7B6A.4CBE4E3B-ON6525782B.0014DC5B-6525782B.001979CB@in.ibm.com>
	 <20110202044222.GC3818@redhat.com>
	 <201102091107.20270.rusty@rustcorp.com.au>
	 <1299621444.25664.77.camel@localhost.localdomain>
Reply-To: habanero@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com,
	Tom Lendacky <tahm@linux.vnet.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1299621444.25664.77.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-03-08 at 13:57 -0800, Shirley Ma wrote:
> On Wed, 2011-02-09 at 11:07 +1030, Rusty Russell wrote:
> > I've finally read this thread... I think we need to get more serious
> > with our stats gathering to diagnose these kind of performance issues.
> > 
> > This is a start; it should tell us what is actually happening to the
> > virtio ring(s) without significant performance impact... 
> 
> Should we also add similar stat on vhost vq as well for monitoring
> vhost_signal & vhost_notify?

Tom L has started using Rusty's patches and found some interesting
results, sent yesterday:
http://marc.info/?l=kvm&m=129953710930124&w=2


-Andrew
> 
> Shirley
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


