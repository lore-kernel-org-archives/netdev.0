From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [net PATCH] mlx4e: Do not attempt to offload VXLAN ports that are
 unrecognized
Date: Thu, 16 Jun 2016 18:09:15 +0300
Message-ID: <b19ffd94-1fd1-68ab-0708-7d2b53510d15@gmail.com>
References: <20160615214105.14734.93787.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexander.duyck@gmail.com
To: Alexander Duyck <aduyck@mirantis.com>, eugenia@mellanox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34342 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388AbcFPPJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 11:09:19 -0400
Received: by mail-wm0-f67.google.com with SMTP id 187so10232440wmz.1
        for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 08:09:19 -0700 (PDT)
In-Reply-To: <20160615214105.14734.93787.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> The mlx4e driver does not support more than one port for VXLAN offload.  As
> such expecting the hardware to offload other ports is invalid since it
> appears the parsing logic is used to perform Tx checksum and segmentation
> offloads.  Use the vxlan_port number to determine in which cases we can
> apply the offload and in which cases we can not.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>

Looks good to me. Thanks Alex!
