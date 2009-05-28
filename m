From: =?ISO-8859-2?Q?Piotr_Duszy=F1ski?= <regis44@gmail.com>
Subject: changing the qdisc class speed rate
Date: Thu, 28 May 2009 07:12:33 +0200
Message-ID: <50214222-779D-4C49-9151-C725C8F470D5@gmail.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:39641 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758181AbZE1FMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 01:12:30 -0400
Received: by ewy24 with SMTP id 24so5005877ewy.37
        for <netdev@vger.kernel.org>; Wed, 27 May 2009 22:12:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I am trying to change the rate parameter of HTB class by using this  
code from within one of my functions :

   struct htb_class *cl;
   cl=htb_find(number,q);

   cl->rate->rate.rate = NEW_RATE_VALUE;

   TC shows the correct values, but the traffic rate doesn't change a  
bit.
   Does anyone have any idea what am I doing wrong ? Maybe there would  
be a faster way by sending a netlink  message ?

Piotrek
