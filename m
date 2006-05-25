From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Thu, 25 May 2006 14:11:03 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F150CE2B@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: ZHOU0022@ntu.edu.sg, baruch@ev-en.org, jmorris@namei.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:35602 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1030419AbWEYVLL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 17:11:11 -0400
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>,
	"David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> On Thu, 25 May 2006 13:23:50 -0700 (PDT) David Miller
> <davem@davemloft.net> wrote: 
> 
>> From: "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>
>> Date: Thu, 25 May 2006 16:30:48 +0800
>> 
>>> Yes, I agree. Actually the main contribution of TCP Veno is not in
>>> this AI phase. No matter the ABC is added or not, TCP Veno can
>>> always improve the performance over wireless networks, according to
>>> our tests.
>> 
>> It seems to me that the wireless issue is seperate from congestion
>> control. 
>> 
>> The key is to identify "true loss" due to overflow of intermediate
>> router queues, vs. "false loss" which is due to temporary radio
>> signal interference.
> 
> Is it really possible to tell the two apart.  

Loss due to "true congestion" as opposed to loss due to radio signal
interference (true loss, but falsely inferred to be congestion) is
actually very possible, at L2 and only if the hop experiencing problems
is the first or last hop. There are numerous indicators that 
the link is experiencing link-related drops (FEC corrections, 
signal to noise, etc.).

The *desirability* of using this data is debatable, but it most
certainly is possible.


