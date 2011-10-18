From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] Fix guest memory leak and panic
Date: Tue, 18 Oct 2011 18:52:19 +0530
Message-ID: <OFF565DE9F.92BF6FE5-ON6525792D.00488336-6525792D.00494D56@in.ibm.com>
References: <20111018080523.16861.55402.sendpatchset@krkumar2.in.ibm.com>	 <1318927016.16132.49.camel@zakaz.uk.xensource.com>
	 <1318931232.16132.65.camel@zakaz.uk.xensource.com>	 <OFB632D60B.6534A38B-ON6525792D.003A1B21-6525792D.003B0DB8@in.ibm.com> <1318935055.3385.0.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318935055.3385.0.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian Campbell <Ian.Campbell@citrix.com> wrote on 10/18/2011 04:20:55 PM:

> > > Sigh, only one out of the ten callers of (__)skb_frag_set_page
expects
> > > skb_frag_set_page to take a new reference. I think that's pretty
> > > comprehensive evidence that the current behaviour is unexpected and
> > > wrong.
> >
> > Looks good!
>
> Thanks.

Tested this patch for virtio_net - hang/panic is fixed.
MemFree also doesn't reduce at end of test compared to
the start.

Tested-by: krkumar2@in.ibm.com

- KK

> > Does it make sense to commit both of these patches? The
> > reason being - my patch becomes a cleanup of set_skb_frag()
> > in virtio_net driver.
>
> I think your patch remains a valid cleanup but I don't maintain that
> code.
>
> Ian.
>
>
