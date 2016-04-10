From: Sagi Grimberg <sagi@grimberg.me>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle facility?
Date: Sun, 10 Apr 2016 21:45:47 +0300
Message-ID: <570A9F5B.5010600@grimberg.me>
References: <1460034425.20949.7.camel@HansenPartnership.com>
 <20160407161715.52635cac@redhat.com> <20160407143854.GA7685@infradead.org>
 <570678B7.7010802@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "lsf@lists.linux-foundation.org" <lsf@lists.linux-foundation.org>,
 Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>,
 James Bottomley <James.Bottomley@HansenPartnership.com>,
 linux-mm <linux-mm@kvack.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
 Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Bart Van Assche <bart.vanassche@sandisk.com>,
 Christoph Hellwig <hch@infradead.org>,
 Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <570678B7.7010802@sandisk.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


>> This is also very interesting for storage targets, which face the same
>> issue.  SCST has a mode where it caches some fully constructed SGLs,
>> which is probably very similar to what NICs want to do.
>
> I think a cached allocator for page sets + the scatterlists that
> describe these page sets would not only be useful for SCSI target
> implementations but also for the Linux SCSI initiator. Today the scsi-mq
> code reserves space in each scsi_cmnd for a scatterlist of
> SCSI_MAX_SG_SEGMENTS. If scatterlists would be cached together with page
> sets less memory would be needed per scsi_cmnd.

If we go down this road how about also attaching some driver opaques
to the page sets?

I know of some drivers that can make good use of those ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
