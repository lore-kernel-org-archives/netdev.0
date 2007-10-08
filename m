From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [PATCH 0/8][BNX2X] resubmit as attachments: New driver for
 Broadcom 10Gb Ethernet, take two.
Date: Mon, 08 Oct 2007 18:15:01 +0200
Message-ID: <470A5785.5010104@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: "davem@davemloft.net" <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>, eilong@broadc
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1416 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732AbXJHQNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 12:13:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[sorry for the mess. resubmitting, this time using attachments, if this 
does not work I'm going to go nuts.]

This is an initial version of the BNX2X, the Linux driver for the
BCM5771X 10Gb Ethernet controller family.
 
Although the chip is very different from the 5706-8 family we based the
driver code on the BNX2 driver.
 
Since the hardware is supposed to be generally available soon I have
posted an initial version and after hearing all the comments I am 
reposting with changes to address them.
 
Some planned feature are still under development, but we want to get
whatever we have out now so people can start using the HW.

Main changes from first version.

* Fixed most issues raised by Michael Buesch. (Thanks Michael!)
* Some slow path bug fixes.
* Yitchak Gertner re-grouped the code in a more logical manner.
* A lot of work was done to get the generated code to comply with coding 
style requirements.

Known issues/TODO.
* Move slowpath event handling from tasklet to workqueue context. This 
will allow replacing the busy waits in the link management code with sleeps.

Please consider applying to 2.6.24

Thanks
Eliezer



