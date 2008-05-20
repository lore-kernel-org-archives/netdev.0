From: "Rune Torgersen" <runet@innovsys.com>
Subject: RE: Oops in fs_enet driver with preempt-rt
Date: Tue, 20 May 2008 11:14:01 -0500
Message-ID: <DCEAAC0833DD314AB0B58112AD99B93B046E73C6@ismail.innsys.innovsys.com>
References: <DCEAAC0833DD314AB0B58112AD99B93B046E728C@ismail.innsys.innovsys.com> <DCEAAC0833DD314AB0B58112AD99B93B046E72C3@ismail.innsys.innovsys.com> <4832F139.1020502@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <linuxppc-dev@ozlabs.org>,
	<netdev@vger.kernel.org>
To: "Scott Wood" <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.innovsys.com ([66.115.232.196]:14885 "EHLO
	mail.innovsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751998AbYETQNd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 12:13:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4832F139.1020502@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood wrote:
> Rune Torgersen wrote:
>> 0xc0196d84 is in fs_enet_interrupt
>> (drivers/net/fs_enet/fs_enet-main.c:473).
>> 468                     if (fpi->use_napi)
>> 469                             int_clr_events &= ~fep->ev_napi_rx;
>> 470 471                     (*fep->ops->clear_int_events)(dev,
>> int_clr_events); 472
>> 473                     if (int_events & fep->ev_err)
>> 474                             (*fep->ops->ev_error)(dev,
>> int_events); 475 476                     if (int_events &
>> fep->ev_rx) { 477                             if (!fpi->use_napi)
>> (gdb)
> 
> Do you have shared interrupt debugging turned on?  That breaks this
> driver, and a patch to remove the shared flag was nacked in favor of
> actually fixing the driver, which I haven't gotten around to.
> 
> -Scott

Hmm.... ttyCPM1 output seems to be kinda garbled... Any ideas?
Incomplete locking between printk and userland use of ttyCPM1 as
console?

kjour[  OK  ]   nal
 stdrtiag. nCom it mnteivalr5 s cones
dXT3EFS  n soa7,dint rnae jolrnau
ElT3-Xs: founmed tilefystsm weth irdeoed ratadmod .
ek/*    [  Removing /var/run/* and /var/locp... [  OK  ]
Creating new /var/run/utmlogin /fastboot and /forcefsck...      OK  ]
Removing possible /etc/noBringing up the loopback interface...  [  OK  ]
OK  ]
OK  ] Entering runlevel: 3 hostname to 9919_unit1_c
Starting the i2c_8266 driver: i2
_82c6: 6odume llcenie 'snspucifeed'itai ts nernkl.
                                                  e[ OK ]


