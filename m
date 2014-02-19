From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v5 1/9] xen-netback: Introduce TX grant map definitions
Date: Wed, 19 Feb 2014 19:19:31 +0000
Message-ID: <530503C3.4050307@citrix.com>
References: <1390253069-25507-1-git-send-email-zoltan.kiss@citrix.com>	 <1390253069-25507-2-git-send-email-zoltan.kiss@citrix.com> <1392744286.23084.52.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392744286.23084.52.camel@kazak.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18/02/14 17:24, Ian Campbell wrote:
> On Mon, 2014-01-20 at 21:24 +0000, Zoltan Kiss wrote:
>>
>> +       spinlock_t dealloc_lock;
>> +       spinlock_t response_lock;
>
> Please add comments to both of these describing what bits of the
> datastructure they are locking.
>
> You might find it is clearer to group the locks and the things they
> protect together rather than grouping the locks together.

Ok, I'll give more description here. The response_lock is actually quite 
relevant to be here, but indeed that's not obvious, I'll explain that as 
well.

Zoli
