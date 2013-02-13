From: Andy Grover <agrover@redhat.com>
Subject: Re: [PATCH] Don't allow multiple TPGs or targets to share a portal
Date: Wed, 13 Feb 2013 14:09:01 -0800
Message-ID: <511C0EFD.9060702@redhat.com>
References: <1360364708-26104-1-git-send-email-agrover@redhat.com> <1360787516.13707.59.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: target-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <1360787516.13707.59.camel@haakon2.linux-iscsi.org>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/13/2013 12:31 PM, Nicholas A. Bellinger wrote:
> On Fri, 2013-02-08 at 15:05 -0800, Andy Grover wrote:
>> RFC 3720 says "Each Network Portal, as utilized by a given iSCSI Node,
>> belongs to exactly one portal group within that node." therefore
>> iscsit_add_np should not check for existing matching portals, it should
>> just go ahead and try to make the portal, and then kernel_bind() will
>> return the proper error.
>>
>> Signed-off-by: Andy Grover <agrover@redhat.com>
>> ---
>
> NACK.  Your interpretation of RFC-3720 is incorrect.  There is nothing
> that says that a single IP address cannot be shared across multiple
> TargetName+TargetPortalGroupTag endpoints.

A Network Portal is ip:port, not just IP. I'd agree two TPGs can use the 
same IP as long as they listen on different ports.

But that bit I quoted seems pretty clear. How should it be alternatively 
interpreted?

Thanks -- Andy
