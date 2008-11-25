From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Is there any function similar to inet_ntoa() in Kernel or NetFilter ?
Date: Mon, 24 Nov 2008 21:03:32 -0500
Message-ID: <AAF075CA-ECF9-440C-AF33-3845544A284D@oracle.com>
References: <192580.22596.qm@web111104.mail.gq1.yahoo.com> <49252F1A.4060304@tihlde.org> <43ca39800811211508i13b3073akfa48284f96eae69c@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Julius Volz <julius.volz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:42736 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbYKYCDk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 21:03:40 -0500
In-Reply-To: <43ca39800811211508i13b3073akfa48284f96eae69c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Nov 21, 2008, at Nov 21, 2008, 6:08 PM, Julius Volz wrote:
> On Thu, Nov 20, 2008 at 10:34 AM, Roar Bj=F8rgum Rotvik <roarbr@tihld=
e.org=20
> > wrote:
>> Kunsheng Chen wrote:
>>> I am doing a project similar to iptable using netfilter, currently =
=20
>>> I want
>>> to convert a IP address from 'long int' back to dotted address.
>>>
>>> I don't know whether there is some functions inside kernel or =20
>>> netfilter
>>> that could make that like using inet_ntoa() in <arpa/inet.h>
>>
>> How about NIPQUAD and NIPQUAD_FMT (for IPv4):
>> http://lxr.linux.no/linux+v2.6.27.6/include/linux/kernel.h#L324
>> http://lxr.linux.no/linux+v2.6.27.6/include/linux/kernel.h#L319
>
> In the latest tree, there are now "%pI4" and "%pI6" format options =20
> for printk.
>
> For example:
>
> printk(KERN_DEBUG "Address: %pI4\n", &v4_addr);

I've been watching this with some interest.  Is this API stable now?

Is there a way to pass a pointer to a sockaddr and get printk() to =20
figure out whether it's is an AF_INET or AF_INET6 address, and display =
=20
it appropriately?

Does it handle IPv6 scope IDs correctly?

Does it convert IPv6 mapped IPv4 addresses to dotted quad automatically=
?

--=20
Chuck Lever
chuck[dot]lever[at]oracle[dot]com