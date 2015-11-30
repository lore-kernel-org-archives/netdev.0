From: Christian Zigotzky <chzigotzky@xenosoft.de>
Subject: [P.A. Semi] Does the ethernet interface work on your Electra, Chitra,
 Nemo, and Athena board?
Date: Mon, 30 Nov 2015 10:50:17 +0100
Message-ID: <565C1BD9.9040404@xenosoft.de>
References: <565AF986.9060106@xenosoft.de>
 <CAOJe8K1911vDjMe9m_1vY6DSGpOk0TmL96Qf1whuNFXxHJesGw@mail.gmail.com>
 <565C1B55.4020207@xenosoft.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.221]:59497 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbbK3JuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 04:50:19 -0500
Received: from [192.168.1.106] (ppp-93-104-85-127.dynamic.mnet-online.de [93.104.85.127])
	by smtp.strato.de (RZmta 37.14 DYNA|AUTH)
	with ESMTPSA id 305c94rAU9oHj8Y
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA (curve secp521r1 with 521 ECDH bits, eq. 15360 bits RSA))
	(Client did not present a certificate)
	for <netdev@vger.kernel.org>;
	Mon, 30 Nov 2015 10:50:17 +0100 (CET)
In-Reply-To: <565C1B55.4020207@xenosoft.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FYI

On 30 November 2015 at 10:48 AM, Christian Zigotzky wrote:
> Hi Denis,
>
> Thank you for your answer. Sorry because of my description.
>
> Yes, the driver probe function finds the device.
>
> With kernel 4.4-rc3:
>
> dmesg | grep -i eth0
>
> [ 2.297473] eth0: PA Semi GMAC: intf 5, hw addr 02:00:e0:0a:30:00
>
> dhclient eth0
>
> RTNETLINK answers: Cannot allocate memory
>
> With kernel 4.1.13:
>
> dmesg | grep -i eth0
>
> [ 2.328115] eth0: PA Semi GMAC: intf 5, hw addr 02:00:e0:0a:30:00
> [ 37.130466] eth0: Link is up at 100 Mbps, full duplex.
>
> Cheers,
>
> Christian
>
> On 30 November 2015 at 09:37 AM, Denis Kirjanov wrote:
>> On 11/29/15, Christian Zigotzky <chzigotzky@xenosoft.de> wrote:
>>> Hi All,
>>>
>>> Does the ethernet interface on your Electra, Chitra, Nemo, and Athena
>>> board work with the release candidates of the kernel 4.4? Unfortunately
>>> the P.A. Semi ethernet doesn't work on our Nemo boards with the release
>>> candidates of the kernel 4.4. We have set the following entries in the
>>> kernel config:
>>>
>>> CONFIG_NET_VENDOR_PASEMI=y
>>> CONFIG_PASEMI_MAC=y
>>>
>>> Could you please test the P.A. Semi ethernet on your P.A. Semi boards?
>> It's not clear from your descriptions what is not working. Does the
>> driver probe function find  a device? Does the interface show up in
>> the kernel? Can it send/receive packets?
>>
>> Also please CC netdev.
>>
>> Thanks.
>>
>>> Thanks in advance,
>>>
>>> Christian
>>> _______________________________________________
>>> Linuxppc-dev mailing list
>>> Linuxppc-dev@lists.ozlabs.org
>>> https://lists.ozlabs.org/listinfo/linuxppc-dev
>
