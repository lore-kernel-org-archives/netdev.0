From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: RTM_NEWLINK not received by application when connecting multiple
 devices simultaneously
Date: Fri, 20 Apr 2012 18:04:49 +0200
Message-ID: <CAKfDRXiPOj64M0oSW9Dc5F0+src3mAjKYna+UM8hwEiHEJXniQ@mail.gmail.com>
References: <CAKfDRXj+mydkzNFC8q2aE_JWHp3ie0cijC-itkm6sHLuZr98Fw@mail.gmail.com>
	<4F90208E.6070201@candelatech.com>
	<20120419075452.379f711b@s6510.linuxnetplumber.net>
	<CAKfDRXjCr0aDSDT8zN8A7_iNX6KAJwrR3NxaB8GAgz5oEiCB3w@mail.gmail.com>
	<CAKfDRXhAqFzPWAJkzhPdZGsUrtjex8uVwHBynCdvA+Zo6sjMig@mail.gmail.com>
	<20120419133635.7d816d67@nehalam.linuxnetplumber.net>
	<CAKfDRXih39RVnx1P72due=_v9-ORWf=YUfUTPKcvVbNzVuTLdw@mail.gmail.com>
	<20120420081400.67a98836@nehalam.linuxnetplumber.net>
	<CAKfDRXgd-9w_PL47OynVL3LX-Z7vG4skGOkQxOLc74=7jWBBXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55928 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754835Ab2DTQEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 12:04:52 -0400
Received: by iagz16 with SMTP id z16so13568624iag.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 09:04:51 -0700 (PDT)
In-Reply-To: <CAKfDRXgd-9w_PL47OynVL3LX-Z7vG4skGOkQxOLc74=7jWBBXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have uploaded a compressed version of my listener code here:
http://pastebin.com/f1NPYGSh

The othe operations my application do related to netlink, is to
configure the sockets. Could it be that the configuration messages
somehow disturb the retrieval of other messages, as they all use the
same mnl_sock? None of them requests any replies (they are all
RTM_NEW*/NLM_F_CREATE), but I am not sure about the internal working
of netlink.
