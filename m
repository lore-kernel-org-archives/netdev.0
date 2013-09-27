From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.40 6/7] datapath: Break out deacceleration portion of vlan_push
Date: Fri, 27 Sep 2013 14:05:08 -0700
Message-ID: <CAEP_g=8mGYwv7fivh1vu6-rMJxZPYAfa3fDS7+_NMdLa+dautA@mail.gmail.com>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
 <1380241116-7661-7-git-send-email-horms@verge.net.au> <20130927194857.GE17506@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <horms@verge.net.au>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:55505 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753316Ab3I0VF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 17:05:29 -0400
Received: by mail-ie0-f180.google.com with SMTP id u16so5017024iet.25
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 14:05:28 -0700 (PDT)
In-Reply-To: <20130927194857.GE17506@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 12:48 PM, Ben Pfaff <blp@nicira.com> wrote:
> On Fri, Sep 27, 2013 at 09:18:35AM +0900, Simon Horman wrote:
>> Break out deacceleration portion of vlan_push into vlan_put
>> so that it may be re-used by mpls_push.
>>
>> For both vlan_push and mpls_push if there is an accelerated VLAN tag
>> present then it should be deaccelerated, adding it to the data of
>> the skb, before the new tag is added.
>>
>> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> I think Jesse already reviewed and approved patches 6 and 7, but I don't
> see any Acked-by attached to them.

There were a few small issues remaining last time, so I'll look
through them again.
