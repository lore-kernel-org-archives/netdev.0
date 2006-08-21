From: Jon Wikne <wikne@cheetah.uio.no>
Subject: Re: sky2 driver - large files upload problem
Date: Mon, 21 Aug 2006 16:21:07 +0200
Message-ID: <44E9C153.1010300@cheetah.uio.no>
References: <44E9A9E0.20106@cheetah.uio.no> <44E9B28C.9050207@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.4]:54962 "EHLO pat.uio.no")
	by vger.kernel.org with ESMTP id S1030509AbWHUOVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 10:21:15 -0400
To: netdev@vger.kernel.org
In-Reply-To: <44E9B28C.9050207@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> 
> Jon Wikne wrote:
> 
>> What happens is typically this: After transeferring some
>> data, ranging from less than 100kB to 10MB, the upload freezes,
>> i.e. gets no further. Use of ping shows the connection is
>> effectively dead. If I do a sequence /sbin/ifdown eth0
>> /sbin/ifup eth0 the upload might resume, but stops again
>> shortly. The phenomenon seems to occur sooner if the path
>> to the remote system is _fast_ (low ping times).
> 
> You can try applying this patch:
> http://developer.osdl.org/shemminger/prototypes/sky2-proc-debug.patch
> 
> It will add a /proc/net/sky2/ethX file, which lists the status of the TX 
> and status rings. You should compare the contents of this file during 
> normal operation to when the interface has hung.

Thanks, Daniel. I applied the patch.

The output of 'cat /proc/net/sky2/eth0' under normal circumstances
is here:

http://puma.uio.no/sky2/sky2-status-normal.txt

After the interface hangs, 'cat /proc/net/sky2/eth0' causes the
whole computer to hang completely. No kernel oops or other
messages in the console window. Power down is the only
solution.... :-[ No log entries after reboot.


-- Jon
