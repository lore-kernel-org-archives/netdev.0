From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC v7 3/5] skb_array: array based FIFO for skbs
Date: Mon, 6 Jun 2016 09:45:09 +0800
Message-ID: <5754D5A5.1080700@redhat.com>
References: <1464883305-32368-1-git-send-email-mst@redhat.com>
 <1464883305-32368-4-git-send-email-mst@redhat.com>
 <20160603145839.2de0ead9@redhat.com>
 <20160603160351-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751770AbcFFBpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jun 2016 21:45:17 -0400
In-Reply-To: <20160603160351-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016=E5=B9=B406=E6=9C=8803=E6=97=A5 21:04, Michael S. Tsirkin wrote:
> On Fri, Jun 03, 2016 at 02:58:39PM +0200, Jesper Dangaard Brouer wrot=
e:
>> >
>> >On Thu, 2 Jun 2016 19:08:26 +0300 "Michael S. Tsirkin"<mst@redhat.c=
om>  wrote:
>> >
>>> > >A simple array based FIFO of pointers.  Intended for net stack s=
o uses
>>> > >skbs for type safety. Implemented as a set of wrappers around pt=
r_array.
>> >                                                                 ^^=
^^^^^^^
>> >It is called "ptr_ring" not "ptr_array".
> Thanks!
> Jason, could you please tweak this when you repost?
>

Sure, looks like Jesper has pointed out some other issues, want me to=20
fix them too? Or you want to post new version yourself?

Thanks
