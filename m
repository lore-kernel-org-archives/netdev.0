From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: Drop linux/socket.h
Date: Fri, 16 Aug 2013 22:29:46 -0700 (PDT)
Message-ID: <20130816.222946.421410239742571372.davem@davemloft.net>
References: <20130816012743.GA5944@hj.localdomain>
	<20130816.003159.2033932881805410431.davem@davemloft.net>
	<20130816092743.GA9918@hj.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	kvm@vger.kernel.org, mst@redhat.com
To: asias@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20130816092743.GA9918@hj.localdomain>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Asias He <asias@redhat.com>
Date: Fri, 16 Aug 2013 17:27:43 +0800

> On Fri, Aug 16, 2013 at 12:31:59AM -0700, David Miller wrote:
>> From: Asias He <asias@redhat.com>
>> Date: Fri, 16 Aug 2013 09:27:43 +0800
>> 
>> > On Thu, Aug 15, 2013 at 02:07:40PM -0700, David Miller wrote:
>> >> From: Asias He <asias@redhat.com>
>> >> Date: Thu, 15 Aug 2013 11:20:16 +0800
>> >> 
>> >> > memcpy_fromiovec is moved to lib/iovec.c. No need to include
>> >> > linux/socket.h for it.
>> >> > 
>> >> > Signed-off-by: Asias He <asias@redhat.com>
>> >> 
>> >> You can't do this.
>> >> 
>> >> Because this file doesn't include the header file that
>> >> provides the declaration, which is linux/uio.h
>> > 
>> > vhost.c includes drivers/vhost/vhost.h. In drivers/vhost/vhost.h, we
>> > have linux/uio.h included.
>> 
>> Nothing in vhost.h needs linux/uio.h right?  That's very poor style,
>> include the header where the dependency exists which is vhost.c
> 
> We use 'struct iovec' in vhost.h which needs linux/uio.h, no?
> 
> So, how about including linux/uio.h in both vhost.c and vhost.h.

That sounds good.
