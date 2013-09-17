From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v3 net-next 07/27] net: add for_each iterators through
 neighbour lower link's private
Date: Tue, 17 Sep 2013 14:29:17 +0200
Message-ID: <20130917122917.GB2929@redhat.com>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
 <1379378812-18346-8-git-send-email-vfalico@redhat.com>
 <1379381203.23881.22.camel@deadeye.wl.decadent.org.uk>
 <20130917073618.GC18195@redhat.com>
 <1379418182.3457.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	jiri@resnulli.us, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205Ab3IQMbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 08:31:12 -0400
Content-Disposition: inline
In-Reply-To: <1379418182.3457.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 04:43:02AM -0700, Eric Dumazet wrote:
>On Tue, 2013-09-17 at 09:36 +0200, Veaceslav Falico wrote:
>> On Tue, Sep 17, 2013 at 02:26:43AM +0100, Ben Hutchings wrote:
>> >On Tue, 2013-09-17 at 02:46 +0200, Veaceslav Falico wrote:
>> >[...]
>> >> --- a/net/core/dev.c
>> >> +++ b/net/core/dev.c
>> >> @@ -4537,6 +4537,72 @@ struct net_device *netdev_all_upper_get_next_dev_rcu(struct net_device *dev,
>> >>  }
>> >>  EXPORT_SYMBOL(netdev_all_upper_get_next_dev_rcu);
>> >>
>> >> +/* netdev_lower_get_next_private - Get the next ->private from the
>> >> + *				   lower neighbour list
>> >[...]
>> >
>> >This is not correct kernel-doc syntax.  You must begin the comment like
>> >this:
>> >
>> >/**
>> > * function_name - summary on one physical line, no wrapping allowed
>>
>> I've thought that netdev specifically requires that type of comments*. But
>> I don't have any strong opinion on that, so if needed - can change easily
>> in the next version.
>>
>> Thanks a lot!
>>
>> *Documentation/networking/netdev-FAQ.txt
>>
>> Q: Someone said that the comment style and coding convention is different
>>     for the networking content.  Is this true?
>>
>> A: Yes, in a largely trivial way.  Instead of this:
>>
>>          /*
>>           * foobar blah blah blah
>>           * another line of text
>>           */
>>
>>     it is requested that you make it look like this:
>>
>>          /* foobar blah blah blah
>>           * another line of text
>>           */
>>
>>
>
>Thats for comments, not kernel-doc sections.
>
>You provided :
>
>+/* netdev_lower_get_next_private - Get the next ->private from the
>+ *                                lower neighbour list
>+ * @dev: device
>+ * @iter: list_head ** of the current position
>+ *
>+ * Gets the next netdev_adjacent->private from the dev's lower neighbour
>+ * list, starting from iter position. The caller must hold either hold the
>+ * RTNL lock or its own locking that guarantees that the neighbour lower
>+ * list will remain unchainged. If iter is NULL - return the first private.
>+ */
>
>Which really looks like a kernel-doc section,
>but misses the proper delimiter which is :

Ok, got it - will fix in the next version.

Thanks all!

>
>/**
>
>Not
>
>/*
>
>
>
