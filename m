From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH v5 1/6] virtio_net: use dev_kfree_skb for small buffer
 XDP receive
Date: Mon, 23 Jan 2017 13:57:31 -0800
Message-ID: <58867C4B.6040704@gmail.com>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117221950.20280.39496.stgit@john-Precision-Tower-5810>
 <20170123230809-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36455 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751082AbdAWV5n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 16:57:43 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so14684053pgf.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 13:57:42 -0800 (PST)
In-Reply-To: <20170123230809-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-23 01:08 PM, Michael S. Tsirkin wrote:
> On Tue, Jan 17, 2017 at 02:19:50PM -0800, John Fastabend wrote:
>> In the small buffer case during driver unload we currently use
>> put_page instead of dev_kfree_skb. Resolve this by adding a check
>> for virtnet mode when checking XDP queue type. Also name the
>> function so that the code reads correctly to match the additional
>> check.
>>
>> Fixes: bb91accf2733 ("virtio-net: XDP support for small buffers")
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> Acked-by: Jason Wang <jasowang@redhat.com>
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> I think we definitely want this one in -net as it's
> a bugfix.
> 

Agreed, let me pull this fix out of the series and submit it for
net.
