From: Matthew Wilcox <matthew@wil.cx>
Subject: iSCSI and scatterlists
Date: Wed, 16 Mar 2005 18:53:10 +0000
Message-ID: <20050316185310.GQ21986@parcelfarce.linux.theplanet.co.uk>
References: <200503160209.j2G29cAf010870@hera.kernel.org> <20050316075839.GC7842@suse.de> <1110986016.5771.3.camel@mulgrave> <20050316160447.GU7842@suse.de> <20050316164806.GO21986@parcelfarce.linux.theplanet.co.uk> <20050316165338.GX7842@suse.de> <20050316170259.GA25056@infradead.org> <20050316170417.GY7842@suse.de> <42387EA2.5020106@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <axboe@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Matthew Wilcox <matthew@wil.cx>,
        James Bottomley <James.Bottomley@SteelEye.com>,
        SCSI Mailing List <linux-scsi@vger.kernel.org>, netdev@oss.sgi.com
To: Mike Christie <mikenc@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <42387EA2.5020106@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 16, 2005 at 10:44:50AM -0800, Mike Christie wrote:
> I got lost here. If you are talking about the need to kmap a sglist then 
> software iscsi has it. iscsi-sfnet used to do
> 
> while (...)
> 	kmap()
> 
> but I fixed that (I think I need to use kmap_atomic though, is that 
> correct or is it just a performance improvement - I am calling kmap from 
> a thread too so). I just added kmap_atomic to open-iscsi and I believe 
> pyx does something similar to the loop above.

Sounds like networking should grow an interface to accept a sglist as
input.  I'm really not familiar with Linux's networking stack to know
how to do it ... cc'ing netdev to get their thoughts.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
