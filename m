From: jamal <hadi@cyberus.ca>
Subject: Re: [Lse-tech] Re: (RFC): SKB Initialization
Date: Tue, 27 Aug 2002 11:49:29 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0208271147320.10164-100000@shell.cyberus.ca>
References: <OFC842923C.BD15E014-ON87256C22.0047BBD6@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Bill Hartner <bhartner@us.ibm.com>, <davem@redhat.com>,
   <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
   Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mala Anand <manand@us.ibm.com>
In-Reply-To: <OFC842923C.BD15E014-ON87256C22.0047BBD6@boulder.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




On Tue, 27 Aug 2002, Mala Anand wrote:

> SPECweb99 profile shows that __kfree_skb is in the top 5 hot routines. We
> will test the skb recycle patch on SPECweb99 and add skbinit patch
> to that and see how it helps.  What I understand is that the skb recycle
> patch does not attempt to recycle if the skbs are allocated on CPU
> and freed on another CPU. Is that right? If so, skbinit patch will help
> those cases.

yes it will. Not significant is my current thinking. i.e i wouldnt write
my mother to tell her about it.

cheers,
jamal
