From: Shirley Ma <mashirle@us.ibm.com>
Subject: [Fwd: Re: [PATCH v2 1/4] Defer skb allocation -- add destroy
 buffers function for virtio]
Date: Tue, 15 Dec 2009 08:13:41 -0800
Message-ID: <1260893621.4387.51.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-6cAzkVcglfd+KSnfq1C/"
To: mst@redhat.com, Rusty Russell <rusty@rustcorp.com.au>,
	Avi Kivity <avi@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759613AbZLOQNt@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-6cAzkVcglfd+KSnfq1C/
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Sorry, forgot to CC all.

Thanks
Shirley

--=-6cAzkVcglfd+KSnfq1C/
Content-Disposition: inline
Content-Description: Forwarded message - Re: [PATCH v2 1/4] Defer skb
 allocation -- add destroy buffers function for virtio
Content-Type: message/rfc822

Return-Path: <mst@redhat.com>
Received: from imap.linux.ibm.com ([unix socket]) by imap.linux.ibm.com
 (Cyrus v2.3.7-Invoca-RPM-2.3.7-7) with LMTPA; Tue, 15 Dec 2009 11:05:23
 -0500
X-Sieve: CMU Sieve 2.3
Received: by imap.linux.ibm.com (Postfix, from userid 101) id 045662E1C068;
 Tue, 15 Dec 2009 11:05:23 -0500 (EST)
X-Spam-TestScore: SPF_HELO_PASS=-0.001,TW_RV=0.077
X-Spam-TokenSummary: Bayes not run.
X-Spam-Checker-Version: SpamAssassin 3.1.7 (2006-10-05) on
 imap.linux.ibm.com
X-Spam-Level: 
X-Spam-Status: No, score=0.1 required=5.0 tests=SPF_HELO_PASS,TW_RV
 autolearn=disabled version=3.1.7
X-Spam-Relay-Country: US ** **
Received: from smtp.linux.ibm.com (smtp.linux.ibm.com [9.26.4.197]) by
 imap.linux.ibm.com (Postfix) with ESMTP id A66322E1C017 for
 <mashirle@imap.linux.ibm.com>; Tue, 15 Dec 2009 11:05:20 -0500 (EST)
Received: from localhost (localhost.localdomain [127.0.0.1]) by
 smtp.linux.ibm.com (Postfix) with ESMTP id 846EAC79F7 for
 <mashirle@linux.ibm.com>; Tue, 15 Dec 2009 11:05:20 -0500 (EST)
X-Virus-Scanned: amavisd-new at linux.ibm.com
Received: from BLDGATE.BOULDER.IBM.COM (bldgate.boulder.ibm.com
 [9.17.210.138]) by smtp.linux.ibm.com (Postfix) with ESMTP id 2B451C79F1
 for <mashirle@linux.ibm.com>; Tue, 15 Dec 2009 11:05:20 -0500 (EST)
Received: by BLDGATE.BOULDER.IBM.COM (IBM VM SMTP Level 540) via spool
 with SMTP id 4416 ; Tue, 15 Dec 2009 09:05:19 MST
Received: by bldgate.vnet.ibm.com (xagent2 6.1.2) via xagsmtp3 with spool
 id 8988 for mashirle@linux.vnet.ibm.com; Tue, 15 Dec 2009 09:05:18 -0700
 (MST)
Received: from d03relay01.boulder.ibm.com [9.17.195.226] by
 BLDGATE.BOULDER.IBM.COM (IBM VM SMTP Level 540) via TCP with ESMTP ; Tue,
 15 Dec 2009 09:05:18 MST
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com
 [9.17.195.245])	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0)
 with ESMTP id nBFG4xcn158618	for <mashirle@us.ibm.com>; Tue, 15 Dec 2009
 09:05:00 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])	by
 d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id
 nBFG6puY031107	for <mashirle@us.ibm.com>; Tue, 15 Dec 2009 09:06:51 -0700
Received: from e38.co.us.ibm.com ([9.17.249.48])	by d03av06.boulder.ibm.com
 (8.14.3/8.13.1/NCO v10.0 AVin) with ESMTP id nBFG6pAw031104
 (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)	for
 <mashirle@us.ibm.com>; Tue, 15 Dec 2009 09:06:51 -0700
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])	by
 e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBFG06jn011911	for
 <mashirle@us.ibm.com>; Tue, 15 Dec 2009 09:00:07 -0700
Received: from int-mx01.intmail.prod.int.phx2.redhat.com
 (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])	by mx1.redhat.com
 (8.13.8/8.13.8) with ESMTP id nBFG4lRc031718	(version=TLSv1/SSLv3
 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)	for <mashirle@us.ibm.com>;
 Tue, 15 Dec 2009 11:04:48 -0500
Received: from redhat.com (dhcp-0-94.tlv.redhat.com [10.35.0.94])	by
 int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with SMTP id
 nBFG4kUS019180	for <mashirle@us.ibm.com>; Tue, 15 Dec 2009 11:04:47 -0500
Date: Tue, 15 Dec 2009 18:02:05 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH v2 1/4] Defer skb allocation -- add destroy buffers
 function for virtio
Message-ID: <20091215160205.GA23883@redhat.com>
References: <200911231123.18898.rusty@rustcorp.com.au>
	 <20091208122134.GA17286@redhat.com>
	 <1260534506.30371.6.camel@localhost.localdomain>
	 <1260534805.30371.10.camel@localhost.localdomain>
	 <20091213102632.GB6789@redhat.com>
	 <1260821285.8716.7.camel@localhost.localdomain>
	 <20091214202253.GG6150@redhat.com>
	 <1260832942.4387.9.camel@localhost.localdomain>
	 <20091215105748.GB11525@redhat.com>
	 <1260892782.4387.38.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1260892782.4387.38.camel@localhost.localdomain>
User-Agent: Mutt/1.5.19 (2009-01-05)
X-Scanned-By: MIMEDefang 2.67 on 10.5.11.11
X-Xagent-From: mst@redhat.com
X-Xagent-To: mashirle@linux.vnet.ibm.com
X-Xagent-Gateway: bldgate.vnet.ibm.com (XAGENTU2 at BLDGATE)
Content-Transfer-Encoding: 7bit

On Tue, Dec 15, 2009 at 07:59:42AM -0800, Shirley Ma wrote:
> Hello Michael,
> 
> On Tue, 2009-12-15 at 12:57 +0200, Michael S. Tsirkin wrote:
> > No, this code would be in virtio net.
> > destroy would simply be the virtqueue API that returns
> > data pointer.
> 
> Since virtio_net doesn't maintain the descriptors of vring, to return
> the data pointer from vq destroy will go through vq->vring.num. It's a
> little expensive. Since it's shutdown code, it might be OK.
> 
> Rusty,
> 
> How do you think? If I change the code something like this, not tested.

Yes, this is basically what I had in mind.
Looks slightly easier to understand than callbacks to me.
But far from critical of course.

> +static void *vring_destroy_bufs(struct virtqueue *_vq, void
> (*destroy)(void *))
> +{
> +       struct vring_virtqueue *vq = to_vvq(_vq);
> +       unsigned int i;
> +
> +       START_USE(vq);
> +
> +       for (i = 0; i < vq->vring.num; i++) {
> +               if (vq->data[i]) {
> +                       /* detach_buf clears data, so grab it now. */
> +                       detach_buf(vq, i);
> +			END_USED(vq);
> +                       return vq->data[i];
> +		}
> +	}  
> +	/* That should have freed everything. */
> +	BUG_ON(vq->num_free != vq->vring.num);
> +	END_USED(vq);
> +	return NULL;	
> +}
> 
>  
> +static void virtnet_free_bufs(struct virtqueue *rvq)
> +{
> +	void *buf;
> +	for (;;) {
> +		buf = rvq->destroy(rvq);
> +		if (!buf) {
> +			BUG_ON(vi->num != 0);
> +			return;
> +       	} else {


Since we have return above, you can put the following code
in the outer block and reduce nesting (without "else").

> +			if (vi->mergeable_rx_bufs || vi->big_packets)
> +				struct page *page, *next;
> +
> +       			for (page = buf; page; page = next) {
> +		        	       next = (struct page *)page->private;    									*)page->private;
> +		        	       __free_pages(page, 0);
> +		       	} else 
> +				kfree_skb(buf);
> +		}
> +		--vi->num;
> +}
> 
> Thanks
> Shirley
> 




--=-6cAzkVcglfd+KSnfq1C/--
