From: "Julius Volz" <julius.volz@gmail.com>
Subject: Re: Is there any function similar to inet_ntoa() in Kernel or NetFilter ?
Date: Sat, 22 Nov 2008 00:08:06 +0100
Message-ID: <43ca39800811211508i13b3073akfa48284f96eae69c@mail.gmail.com>
References: <192580.22596.qm@web111104.mail.gq1.yahoo.com>
	 <49252F1A.4060304@tihlde.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux_kernel_chan@yahoo.com, netdev@vger.kernel.org
To: "=?ISO-8859-1?Q?Roar_Bj=F8rgum_Rotvik?=" <roarbr@tihlde.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:30450 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbYKUXII convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 18:08:08 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1153525rvb.1
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 15:08:06 -0800 (PST)
In-Reply-To: <49252F1A.4060304@tihlde.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 20, 2008 at 10:34 AM, Roar Bj=F8rgum Rotvik <roarbr@tihlde.=
org> wrote:
> Kunsheng Chen wrote:
>> I am doing a project similar to iptable using netfilter, currently I=
 want
>> to convert a IP address from 'long int' back to dotted address.
>>
>> I don't know whether there is some functions inside kernel or netfil=
ter
>> that could make that like using inet_ntoa() in <arpa/inet.h>
>
> How about NIPQUAD and NIPQUAD_FMT (for IPv4):
> http://lxr.linux.no/linux+v2.6.27.6/include/linux/kernel.h#L324
> http://lxr.linux.no/linux+v2.6.27.6/include/linux/kernel.h#L319

In the latest tree, there are now "%pI4" and "%pI6" format options for =
printk.

=46or example:

printk(KERN_DEBUG "Address: %pI4\n", &v4_addr);

Julius
