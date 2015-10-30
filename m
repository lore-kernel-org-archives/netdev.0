From: =?UTF-8?B?56We5qW95Z2C546y5aWI?= <zh99998@gmail.com>
Subject: ip rule tos not works on many tos value
Date: Fri, 30 Oct 2015 10:39:08 +0800
Message-ID: <CAP8bwDW0guARPQZi4CGk7ZeuqWoeUBHN=NoO5Zu=5o0mqMN4vA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35860 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757653AbbJ3Cj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 22:39:28 -0400
Received: by ioll68 with SMTP id l68so67058314iol.3
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 19:39:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

```
# ip rule add tos 0x10 lookup 1    # run successfully
# ip rule add tos 0x20 lookup 2
RTNETLINK answers: Invalid argument
```

i tried all 1-255 tos values, and find just these values can be used:

2
4
6
8
10
12
14
16
18

what should i do if i want to use more tos value?

```
$ cat /etc/iproute2/rt_dsfield
# Differentiated field values
# These include the DSCP and unused bits
0x0     default
# Newer RFC2597 values
0x28    AF11
0x30    AF12
0x38    AF13
0x48    AF21
0x50    AF22
0x58    AF23
0x68    AF31
0x70    AF32
0x78    AF33
0x88    AF41
0x90    AF42
0x98    AF43
# Older values RFC2474
0x20    CS1
0x40    CS2
0x60    CS3
0x80    CS4
0xA0    CS5
0xC0    CS6
0xE0    CS7
# RFC 2598
0xB8    EF
```
