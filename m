From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] gianfar:don't add FCB length to hard_header_len
Date: Thu, 24 May 2012 17:04:34 +0200
Message-ID: <4FBE4E02.1070306@computer.org>
References: <1337677248-27792-1-git-send-email-b06378@freescale.com> <20120522.151830.2018953337014839778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: b06378@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:55665 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932495Ab2EXPHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 11:07:53 -0400
In-Reply-To: <20120522.151830.2018953337014839778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/22/2012 09:18 PM, David Miller wrote:
> From: Jiajun Wu <b06378@freescale.com>
> Date: Tue, 22 May 2012 17:00:48 +0800
> 
>> FCB(Frame Control Block) isn't the part of netdev hard header.
>> Add FCB to hard_header_len will make GRO fail at MAC comparision stage.
>>
>> Signed-off-by: Jiajun Wu <b06378@freescale.com>
> 
> Applied, thanks.
> 
> Someone needs to go through this driver when net-next opens up
> and fix all of the indentation in this driver.

May I give that a go?
