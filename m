From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] vhost_net: a kernel-level virtio server
Date: Thu, 13 Aug 2009 09:31:13 +0300
Message-ID: <20090813063113.GA3508@redhat.com>
References: <cover.1249930169.git.mst@redhat.com> <200908121903.22325.arnd@arndb.de> <20090812172141.GA29966@redhat.com> <200908121959.47222.arnd@arndb.de> <4A8317A3.4030303@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	virtualization@lists.linux-foundation.org,
	"Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4A8317A3.4030303@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 12, 2009 at 02:27:31PM -0500, Anthony Liguori wrote:
> Arnd Bergmann wrote:
>>> As I pointed out earlier, most code in virtio net is asymmetrical: guest
>>> provides buffers, host consumes them.  Possibly, one could use virtio
>>> rings in a symmetrical way, but support of existing guest virtio net
>>> means there's almost no shared code.
>>>     
>>
>> The trick is to swap the virtqueues instead. virtio-net is actually
>> mostly symmetric in just the same way that the physical wires on a
>> twisted pair ethernet are symmetric (I like how that analogy fits).
>>   
>
> It's already been done between two guests.  See  
> http://article.gmane.org/gmane.linux.kernel.virtualization/5423
>
> Regards,
>
> Anthony Liguori

Yes, this works by copying data (see PATCH 5/5).  Another possibility is
page flipping.  Either will kill performance.

-- 
MST
