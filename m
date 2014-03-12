From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net 0/3] mlx4 fixes
Date: Wed, 12 Mar 2014 22:25:16 +0200
Message-ID: <CAJZOPZKg20NEcccq5FT4EM-c-7PEDp3veZk8cbfbPqKnhE2P_g@mail.gmail.com>
References: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com>
	<20140312.161408.2149985285610209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:44674 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbaCLUZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 16:25:17 -0400
Received: by mail-pa0-f53.google.com with SMTP id ld10so32698pab.40
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 13:25:16 -0700 (PDT)
In-Reply-To: <20140312.161408.2149985285610209.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 12, 2014 at 10:14 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>
> Date: Wed, 12 Mar 2014 17:16:29 +0200
>
>> These short series fixes two bugs related to the vxlan support and a
>> missing req module call for the IB driver which is needed to support
>> IB/RDMA over Ethernet.
>>
>> Pathes done over the net tree, commit dd38743 "vlan: Set correct
>> source MAC address with TX VLAN offload enabled"
>
> Series applied, thanks Or.
>
> I wonder though, if a MAC address change results in a VLAN steering
> rule insertion failure, won't we be left in an inconsistent state?

in that case non-VXLAN traffic will fly in OK, but not VXLAN traffic.
I don't think we want to close the shop when this happens but probably
print some warning or a like, will send a patch...
