From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Re: [PATCH iproute2] iproute2: add vxlan dstport option
Date: Fri, 10 May 2013 15:12:16 -0700
Message-ID: <518D70C0.6070106@gmail.com>
References: <20130427213151.255971631@vyatta.com> <20130427213258.534077786@vyatta.com> <20130427144747.48ace4fb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	David L Stevens <dlstevens@us.ibm.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:46196 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245Ab3EJWMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 May 2013 18:12:15 -0400
Received: by mail-oa0-f47.google.com with SMTP id m1so1632179oag.34
        for <netdev@vger.kernel.org>; Fri, 10 May 2013 15:12:14 -0700 (PDT)
In-Reply-To: <20130427144747.48ace4fb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/2013 2:47 PM, Stephen Hemminger wrote:
> Add ability to set UDP destination port on a per device basis.
> If no port is assigned, the default IANA assigned port will be used.
> If you want the kernel default value, then use port 0.
>
> Source port range option is now called 'srcport', to avoid
> confusion. The old option syntax is accepted for compatiablity.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

I updated iproute2 to the upstream git tree and i noticed that vxlan
connectivity is lost in my setup as this patch is causing vxlan packets 
to be
sent to the new IANA port 4789, but the kernel default is 8472 and the
receiver is listening on that port.

If we are going to keep 8472 as the kernel default for listening port, i 
think iproute2
also should keep the same default for dst_port.

Thanks
Sridhar
