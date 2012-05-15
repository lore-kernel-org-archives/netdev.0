From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 1/8] net/mlx4: Address build warnings on set
 but not used variables
Date: Tue, 15 May 2012 09:16:58 +0300
Message-ID: <4FB1F4DA.9050403@mellanox.com>
References: <1337025853-26685-2-git-send-email-ogerlitz@mellanox.com> <20120515.000754.1011080018257342361.davem@davemloft.net> <4FB1EF06.6070909@mellanox.com> <20120515.015916.1228365475475285173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roland@kernel.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:47732 "HELO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754188Ab2EOGR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 02:17:57 -0400
In-Reply-To: <20120515.015916.1228365475475285173.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/15/2012 8:59 AM, David Miller wrote:
> I can't tell if it's right, becuase it got all reformatted by your 
> mail client. You simply need to make sure the arguments on the second 
> and further lines line up with the column after the openning 
> parenthesis on the first line. 

Oh I see you point now, indeed, there were two cases in this patch where 
I replaced "err = "  which spans six chars with "(void) "  which spans 
seven, so what I needs to be done here is to add a tab in the 2nd, etc 
lines or a space? BTW there are such changes only in this patch (1/8).

Or.
