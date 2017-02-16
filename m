From: Chuck Lever <chuck.lever-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH rfc 0/4] Introduce a new helper for parsing ipv[4|6]:port to socket address
Date: Thu, 16 Feb 2017 12:59:24 -0500
Message-ID: <EB281BA3-28DB-4DBA-BA3B-31A98BC0D44E@oracle.com>
References: <1487267017-29904-1-git-send-email-sagi@grimberg.me> <AD117189-9D24-4C5C-9751-9EA6B27575B1@oracle.com> <8dc41cfc-85b2-fb42-61b0-5be499fa7ad0@grimberg.me>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        List Linux RDMA Mailing <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <8dc41cfc-85b2-fb42-61b0-5be499fa7ad0-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> On Feb 16, 2017, at 12:53 PM, Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org> wrote:
> 
> Hey Chuck,
> 
>>> As a side-effect, this set adds ipv6 support for nvme over fabrics.
>>> I also converted iscsi target and plan to convert nfs/cifs next but
>>> wanted to get some feedback before doing that.
>> 
>> At least NFS/RDMA already supports IPv6. You might not need many
>> changes there, but I'll hold off on further comments.
> 
> Yea, I wanted to get all the rpc_pton/rpc_ntop (which handle both
> ipv4 and ipv6 with scopes) converted to use a common helper.

RPC is dealing with universal addresses, which are not quite the
same as IP presentation addresses. The port number is expressed
as:

  hi8.lo8

And universal IPv6 addresses don't have a mechanism for conveying
scope information.


--
Chuck Lever



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
