From: "allan" <allan@asix.com.tw>
Subject: RE: [PATCH] asix: new device id
Date: Tue, 20 Dec 2011 08:41:32 +0800
Message-ID: <003d01ccbeb0$22f14320$68d3c960$@com.tw>
References: <20111216.133227.782560339712731597.davem@davemloft.net>	<1324068562-3761-1-git-send-email-aurel@gnuage.org>	<20111219.160059.783127741333326755.davem@davemloft.net> <CANEJEGswxaxgD9eet9uDZm6Ezf67ibG0XOTggSBONZ6M1KMErA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: <aurel@gnuage.org>, <netdev@vger.kernel.org>,
	"'Freddy Xin'" <freddy@asix.com.tw>,
	=?utf-8?B?QVNJWCBMb3VpcyBb6JiH5aiB6Zm4XQ==?= <louis@asix.com.tw>
To: "'Grant Grundler'" <grundler@google.com>,
	"'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from asix.com.tw ([113.196.140.82]:64633 "EHLO asix.com.tw"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752335Ab1LTAl7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 19:41:59 -0500
In-Reply-To: <CANEJEGswxaxgD9eet9uDZm6Ezf67ibG0XOTggSBONZ6M1KMErA@mail.gmail.com>
Content-Language: zh-tw
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David,

ASUS's USB to Ethernet adapter (delivered with Zenbook) implemented ASIX's latest USB 2.0 to Fast Ethernet solution, AX88772B inside. ASUS hopes to enable the WOL function on Windows system by default so we assigned a new VID/PID (0B95h/7E2Bh) to meet their requirement. 

For Linux native driver, you can easily add the new VID/PID (0B95h/7E2Bh) to work as the AX88772B (with default VID/PID, 0B95h/772Bh). Please feel free to let us know if you have any problems or need more information. Thanks a lot for your great helps.


---
Best regards,
Allan Chou
Technical Support Division
ASIX Electronics Corporation
TEL: 886-3-5799500 ext.228
FAX: 886-3-5799558
E-mail: allan@asix.com.tw 
http://www.asix.com.tw/ 

-----Original Message-----
From: Grant Grundler [mailto:grundler@google.com] 
Sent: Tuesday, December 20, 2011 5:23 AM
To: David Miller
Cc: aurel@gnuage.org; netdev@vger.kernel.org; Allan Chou; Freddy Xin
Subject: Re: [PATCH] asix: new device id

On Mon, Dec 19, 2011 at 1:00 PM, David Miller <davem@davemloft.net> wrote:
> From: Aurelien Jacobs <aurel@gnuage.org>
> Date: Fri, 16 Dec 2011 21:49:22 +0100
>
>> Adds the device id needed for the USB Ethernet Adapter delivered by
>> ASUS with their Zenbook.
>>
>> Signed-off-by: Aurelien Jacobs <aurel@gnuage.org>
>
> Grant, ACK/NACK?

Dave,
I'm totally ok with it if Aurelien is confident it "works" (well enough).

I'm really the wrong guy to ask though. I don't have the device
and I'm not associated with the mfg.

The right people to ask (CC'd) are Allan Chou and Freddy Xin (both from ASIX).

cheers!
grant
