From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 4/4] bridge: vlan: combine (br|nbp)_vlan_flush
 into one
Date: Mon, 12 Oct 2015 23:41:33 -0700
Message-ID: <CAE4R7bCNFAOPjf19DgGYmLChds6z5NmSYG5qmqAXGKYHySh-PQ@mail.gmail.com>
References: <1444650069-32572-1-git-send-email-razor@blackwall.org>
 <1444650069-32572-5-git-send-email-razor@blackwall.org> <20151012175156.GA16784@colbert.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nikolay Aleksandrov <razor@blackwall.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36759 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbbJMGlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 02:41:53 -0400
Received: by oihr205 with SMTP id r205so4371224oih.3
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 23:41:52 -0700 (PDT)
In-Reply-To: <20151012175156.GA16784@colbert.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2015 at 10:51 AM, Ido Schimmel <idosch@mellanox.com> wrote:
> Mon, Oct 12, 2015 at 02:41:09PM IDT, razor@blackwall.org wrote:
>>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>
>>As Ido Schimmel pointed out the vlan_vid_del() loop in nbp_vlan_flush is
>>unnecessary (and is actually a remnant of the old vlan code) so we can
>>remove it and combine both br/nbp vlan_flush functions into one.
> Just a small note to Scott and Vivien:
>
> One of the side effects of Nik's recent patchsets is that when VLANs are
> flushed on a port the deletion is propagated to the driver via
> switchdev ops, as __vlan_vid_del is called.
>
> Therefore there is no need to do internal bookkeeping and remove VLANs
> yourself when port is removed from bridge.

Thanks for the heads-up.  Seems like a nice result.
