From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: IP/UDP encapsulation
Date: Thu, 8 Apr 2010 19:18:31 +0930
Message-ID: <20100408191831.08cd8d7b@opy.nosense.org>
References: <20100408074247.GA19798@vigoh>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marco bonola <marco.bonola@gmail.com>,
	"ZioPRoTo (Saverio Proto)" <zioproto@gmail.com>,
	Behling Mario <mb@mariobehling.de>,
	"L. Aaron Kaplan" <aaron@lo-res.org>
To: "Gustavo F. Padovan" <gustavo@padovan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:41504 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758302Ab0DHJso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 05:48:44 -0400
In-Reply-To: <20100408074247.GA19798@vigoh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 8 Apr 2010 04:42:47 -0300
"Gustavo F. Padovan" <gustavo@padovan.org> wrote:

> Hi,
> 
> I'm looking for some advice on that work. The Freifunk organization is
> planning work on the IP/UDP encapsulation kernel module as a GSoC
> project. The idea is to create a IP-in-UDP tunnel like we do for
> IP-in-IP or IP-in-GRE tunnels. The only way to do that today is to use
> some VPN software.
> 
> The module will export its virtual interface through sockets and will
> have support for the standard syscalls like the others encapsulation
> modules.
> 
> It will improve the performance of mesh networks that will we be able
> to use IP-in-UDP rather than IP-in-IP.

I'm a bit confused. How can tunnelling IP in UDP in IP be faster than IP in IP?


> So, instead of push all data to
> local gateway into the mesh all the data can be tunneled to a faster
> server and from there to the Internet. With all the data exiting with
> the same IP address (the fast server IP). That will improve bandwidth,
> especially for upload.
> 
> Is such module acceptable for merge into the Linux Kernel?
> 
> Any comments or suggestions to the module architecture and
> implementation? If you want more information about the module I can
> provide that.
> 
> Regards,
> 
> -- 
> Gustavo F. Padovan
> http://padovan.org
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
