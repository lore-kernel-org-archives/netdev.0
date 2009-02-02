From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH v3 1/4] virtio_net: Add a virtqueue for outbound control
 commands
Date: Mon, 02 Feb 2009 08:10:04 -0600
Message-ID: <4986FEBC.6000404@codemonkey.ws>
References: <20090201200504.8183.58421.stgit@debian.lart> <20090201200509.8183.4996.stgit@debian.lart> <200902022010.54829.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alex Williamson <alex.williamson@hp.com>, markmc@redhat.com,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200902022010.54829.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alex,

Can you post the userspace side of this to qemu-devel (against QEMU SVN) 
and I'll review/apply.  I've already looked through the series a couple 
times and I don't think there are any major issues.

Regards,

Anthony Liguori

Rusty Russell wrote:
> On Monday 02 February 2009 06:35:10 Alex Williamson wrote:
>
>   
>> +static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
>> +				 struct scatterlist data[], int out, int in)
>> +{
>> +	struct scatterlist sg[VIRTIO_NET_MAX_CTRL_ARGS];
>>     
> ...
>   
>> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
>> index f76bd4a..f28a72a 100644
>> --- a/include/linux/virtio_net.h
>> +++ b/include/linux/virtio_net.h
>>     
> ...
>   
>> +#define VIRTIO_NET_MAX_CTRL_ARGS   2
>>     
>
> I think this definition belongs at the top of virtio_net.c; the others
> are userspace-exposed, this is really an internal issue, no?
>
> Other than that, you can add Acked-by: Rusty Russell <rusty@rustcorp.com.au>
> and send to netdev for DaveM's tree.
>
> Thanks!
> Rusty.
> --
> To unsubscribe from this list: send the line "unsubscribe kvm" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

