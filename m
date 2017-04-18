From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: NFS over NAT causes e1000e transmit hangs
Date: Tue, 18 Apr 2017 12:05:11 -0700
Message-ID: <9fa24846-3a2d-26d3-2963-f5e6ec6808a5@gmail.com>
References: <42af0e78-3107-1605-f8e1-d73a8c441ff0@gmail.com>
 <1492542204.10587.138.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32783 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753374AbdDRTFS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 15:05:18 -0400
Received: by mail-pf0-f195.google.com with SMTP id c198so282152pfc.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 12:05:18 -0700 (PDT)
In-Reply-To: <1492542204.10587.138.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2017 12:03 PM, Eric Dumazet wrote:
> On Tue, 2017-04-18 at 11:18 -0700, Florian Fainelli wrote:
>> Hi,
>>
>> I am using NFS over a NAT with two e1000e adapters and with eth1 being
>> the LAN interface and eth0 the WAN interface. The kernel is Ubuntu's
>> 16.10 kernel: 4.8.0-46-generic. The device doing NAT over NFS is just
>> mounting a remote folder and doing normal execution/file accesses. It's
>> enough to untar a file from this device onto a NFS share to expose the
>> problem.
>>
>> The transmit hangs look like the ones below, doing a rmmod/insmod does
>> not help eliminated the problem, nor does a power cycle. Stopping the
>> NFS over NAT definitively does let the adapter recover.
> 
> Is this NFS over TCP or UDP ?

This is NFS over TCP mounted with the following:

type nfs
(rw,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=2049,timeo=70,retrans=3,sec=sys,local_lock=none,addr=X.X.X.X)

Thanks Eric!
-- 
Florian
