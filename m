From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V2 12/12] net/mlx5: Ethernet driver
Date: Tue, 21 Apr 2015 16:30:40 +0300
Message-ID: <55365100.4060208@mellanox.com>
References: <1428999635-15025-1-git-send-email-amirv@mellanox.com>
	<1428999635-15025-13-git-send-email-amirv@mellanox.com>
 <20150414.145113.192331451516214119.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yevgenyp@mellanox.com>, <saeedm@mellanox.com>,
	<achiad@mellanox.com>, <idos@mellanox.com>, <talal@mellanox.com>
To: <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0070.outbound.protection.outlook.com ([157.55.234.70]:27706
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754056AbbDUNaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2015 09:30:52 -0400
In-Reply-To: <20150414.145113.192331451516214119.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/14/2015 9:51 PM, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Tue, 14 Apr 2015 11:20:35 +0300
>
>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> What does "Ethernet driver" mean?
>
> Are you adding a new ethernet driver?  If so, what is it for and how
> does it interact with the existing mlx5 driver?
>
> It looks to me like you are adding a lot of code and objects to the
> existing mlx5 module.  An incredible amount, in fact.  This seems very
> suboptimal especially for users of the existing mlx5 chips.

Hi Dave,

To clarify things a bit, the mlx5 driver serves two NICs families: 
ConnectIB (device IDs 0x1011/12) and ConnectX4 (device IDs 1013-1016).

ConnectIB HW is IB only, ConnextX4 is IB and Ethernet.

This submission enhances the driver to support Ethernet for the 
ConnectX4 family.

In a similar manner to the mlx4 driver stacking, mlx5 has has IB driver 
and core driver. Per your comments, in V3, the Ethernet functionality 
would be added per dedicated config directive, such that if someone 
wants only the IB driver to be functional, the Ethernet netdev code and 
such doesn't get built.





> You haven't discussed this, what design decisions made you decide in the end to do it this way, etc.
>
> You absolutely have to say something other than "Ethernet driver"
> in this commit message, I expect several paragraphs of details
> and the hows and whys of the change as it is a non-trivial amount
> of code being added here.

Understood, will add more text to the cover letter, change-logs, etc.


> I still consider this patch series not ready yet, and the merge
> window is open thus closing the net-next tree.
>
> You will therefore need to wait until the net-next tree opens
> again before submitting this series again.

Sure, thanks for the review feedback provided so far.

BTW Sorry for the late reply, just realized today there has been no 
response on your comments.

Or.
