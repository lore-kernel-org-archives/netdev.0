From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v3 net-next 07/27] net: add for_each iterators through
 neighbour lower link's private
Date: Tue, 17 Sep 2013 09:36:18 +0200
Message-ID: <20130917073618.GC18195@redhat.com>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
 <1379378812-18346-8-git-send-email-vfalico@redhat.com>
 <1379381203.23881.22.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32313 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751682Ab3IQHf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 03:35:59 -0400
Content-Disposition: inline
In-Reply-To: <1379381203.23881.22.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 02:26:43AM +0100, Ben Hutchings wrote:
>On Tue, 2013-09-17 at 02:46 +0200, Veaceslav Falico wrote:
>[...]
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -4537,6 +4537,72 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
>>  }
>>  EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
>>
>> +/* netdev_lower_get_next_private - Get the next ->private from the
>> + *				   lower neighbour list
>[...]
>
>This is not correct kernel-doc syntax.  You must begin the comment like
>this:
>
>/**
> * function_name - summary on one physical line, no wrapping allowed

I've thought that netdev specifically requires that type of comments*. But
I don't have any strong opinion on that, so if needed - can change easily
in the next version.

Thanks a lot!

*Documentation/networking/netdev-FAQ.txt

Q: Someone said that the comment style and coding convention is different
    for the networking content.  Is this true?

A: Yes, in a largely trivial way.  Instead of this:

         /*
          * foobar blah blah blah
          * another line of text
          */

    it is requested that you make it look like this:

         /* foobar blah blah blah
          * another line of text
          */


>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
