From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net V1 0/3] mlx5 driver fixes for 4.5-rc2
Date: Sun, 7 Feb 2016 17:44:32 +0200
Message-ID: <56B76660.4050105@mellanox.com>
References: <1454426781-7128-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Saeed Mahameed <saeedm@mellanox.com>,
	"Matan Barak" <matanb@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0072.outbound.protection.outlook.com ([157.55.234.72]:23716
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750980AbcBGQTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2016 11:19:22 -0500
In-Reply-To: <1454426781-7128-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/2/2016 5:26 PM, Or Gerlitz wrote:
> We added here a patch from Matan and Alaa for addressing Linus comments on
> the mess w.r.t reserved field names in the driver/firmware auto-generated file.
>
> Once the patch hits linus tree, we'll ask Doug to rebase his tree on that
> rc so both net-next and rdma-next development for 4.6 will be done under
> the fixed robust form.

Hi Dave,

We've identified few places in the auto generated file where the naming 
conversion
of reserved fields was not fully applied. Since the patch only did 
re-naming of
reserved fields which are not used for existing functionality, the 
testing we did
under the modified header file didn't catch that...

We'll respin the patch and series.

Or.
