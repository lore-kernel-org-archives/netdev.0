From: thomas yang <lampsu@gmail.com>
Subject: [iproute2] a 'ip rule ...' bug?
Date: Fri, 26 Mar 2010 20:15:30 +0800
Message-ID: <f4f837ab1003260515y54f0db76vc19c966f39e1d3a1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:54469 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751473Ab0CZMPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 08:15:31 -0400
Received: by pva18 with SMTP id 18so1323510pva.19
        for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 05:15:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in  /etc/iproute2/rt_dsfield
...
# Newer RFC2597 values
0x28	AF11
0x30	AF12
0x38	AF13
...

---in   ip  man page ---
ip rule add - insert a new rule

tos TOS
dsfield TOS
    select the TOS value to match.
---

[root@localhost ~]# ip rule add dsfield 0x28 table 200
Error: argument "dsfield" is wrong: Failed to parse rule type

why???
how to match 'dsfield' ?

[root@localhost ~]# ip rule add tos 0x28 table 200
RTNETLINK answers: Invalid argument

(My OS is Fedora 11 :  kernel-2.6.30.10-105.2.23.fc11.i586 ,
iproute-2.6.29-2.fc11.i586 ;
on my another linux box ( Fedora 7)   'ip rule'  also has the same
problem  to match  tos and dsfield. )


--
Tom
