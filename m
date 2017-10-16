From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront, xen-netback: Use correct minimum MTU
 values
Date: Mon, 16 Oct 2017 21:22:23 +0100 (WEST)
Message-ID: <20171016.212223.777323721927998324.davem@davemloft.net>
References: <1508160032-21689-1-git-send-email-mgamal@redhat.com>
        <20171016150522.nebui653rkjove7r@citrix.com>
        <3da3d5ae-c2cb-380e-368d-a90432608cf1@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, mgamal@redhat.com, netdev@vger.kernel.org,
        xen-devel@lists.xenproject.org, paul.durrant@citrix.com,
        linux-kernel@vger.kernel.org, vkuznets@redhat.com,
        otubo@redhat.com, cavery@redhat.com, cheshi@redhat.com,
        jgross@suse.com
To: boris.ostrovsky@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3da3d5ae-c2cb-380e-368d-a90432608cf1@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Mon, 16 Oct 2017 16:19:07 -0400

> On 10/16/2017 11:05 AM, Wei Liu wrote:
>> On Mon, Oct 16, 2017 at 03:20:32PM +0200, Mohammed Gamal wrote:
>>> RFC791 specifies the minimum MTU to be 68, while xen-net{front|back}
>>> drivers use a minimum value of 0.
>>>
>>> When set MTU to 0~67 with xen_net{front|back} driver, the network
>>> will become unreachable immediately, the guest can no longer be pinged.
>>>
>>> xen_net{front|back} should not allow the user to set this value which causes
>>> network problems.
>>>
>>> Reported-by: Chen Shi <cheshi@redhat.com>
>>> Signed-off-by: Mohammed Gamal <mgamal@redhat.com>
>> Acked-by: Wei Liu <wei.liu2@citrix.com>
>>
>> CC netfront maintainers
> 
> 
> Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> 
> I can take it via Xen tree unless there are objections.

No problem on my end.
