From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 6/6] bridge: a netlink notification should be
 sent when those attributes are changed by ioctl
Date: Wed, 16 Mar 2016 15:28:35 +0100
Message-ID: <56E96D93.2040308@cumulusnetworks.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
 <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
 <f379a033c5b7798906c57dd1bb67df89b7de02cb.1458134414.git.lucien.xin@gmail.com>
 <45f430c026ce8a2fb358c650a41452aebff9ec36.1458134414.git.lucien.xin@gmail.com>
 <38a10eecc6347a3c47b55c86b4783c49b6dbbc99.1458134414.git.lucien.xin@gmail.com>
 <7c788b65786582209a3ba4bc4d4ed279f6f77568.1458134414.git.lucien.xin@gmail.com>
 <9cadf4925a11b60a5420406b4eb164e9a2d13b50.1458134414.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:37974 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934415AbcCPO2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 10:28:37 -0400
Received: by mail-wm0-f44.google.com with SMTP id l68so75201256wml.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 07:28:37 -0700 (PDT)
In-Reply-To: <9cadf4925a11b60a5420406b4eb164e9a2d13b50.1458134414.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2016 02:34 PM, Xin Long wrote:
> Now when we change the attributes of bridge or br_port by netlink,
> a relevant netlink notification will be sent, but if we change them
> by ioctl or sysfs, no notification will be sent.
> 
> We should ensure that whenever those attributes change internally or from
> sysfs/ioctl, that a netlink notification is sent out to listeners.
> 
> Also, NetworkManager will use this in the future to listen for out-of-band
> bridge master attribute updates and incorporate them into the runtime
> configuration.
> 
> This patch is used for ioctl.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/bridge/br_ioctl.c | 40 ++++++++++++++++++++++++----------------
>  1 file changed, 24 insertions(+), 16 deletions(-)
> 

LGTM,

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
