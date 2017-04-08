From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net v2 1/2] bridge: implement missing ndo_uninit()
Date: Sat, 8 Apr 2017 17:05:48 +0300
Message-ID: <59220a2b-aa54-844d-cda5-63a42b88f188@cumulusnetworks.com>
References: <20170408114159.12722-1-idosch@mellanox.com>
 <20170408114159.12722-2-idosch@mellanox.com>
 <20170408093042.20b08c5d@plumbers-lap.home.lan>
 <20170408134938.GA28955@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: idosch@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
        bridge@lists.linux-foundation.org, peter@svinota.eu, cera@cera.cz,
        mlxsw@mellanox.com
To: Ido Schimmel <idosch@idosch.org>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:33144 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751674AbdDHOFv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 10:05:51 -0400
Received: by mail-wr0-f172.google.com with SMTP id g19so80356138wrb.0
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 07:05:50 -0700 (PDT)
In-Reply-To: <20170408134938.GA28955@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/17 16:49, Ido Schimmel wrote:
> On Sat, Apr 08, 2017 at 09:30:42AM -0400, Stephen Hemminger wrote:
>> On Sat, 8 Apr 2017 14:41:58 +0300
>> <idosch@mellanox.com> wrote:
>>
>>>  static void br_dev_free(struct net_device *dev)
>>>  {
>>> -	struct net_bridge *br = netdev_priv(dev);
>>> -
>>> -	free_percpu(br->stats);
>>>  	free_netdev(dev);
>>>  }
>>>  
>>
>> Since the only thing left is free_netdev, you can now just set dev->destructor
>> to be free_netdev.
> 
> Fine.
> 
> Beside stylistic issues, I would appreciate comments on how this should
> be handled. Are we reverting the patch in the Fixes line or applying
> this patchset?
> 
> I prefer the first option. Then after net is merged into net-next I can
> re-post this patchset with the requested changes.
> 

+1
