From: Krishna Mohan <krishnamohany3k@gmail.com>
Subject: Fwd: Loopback properties in routing on linux kernel
Date: Tue, 7 Jun 2016 16:16:02 +0530
Message-ID: <CAE+=0-jQo14t232RVsV2o=BmbX3T0kphAjbvaAhT3cnxzc5gqg@mail.gmail.com>
References: <CAE+=0-gQEwaAz79HoRsQGjvuTjiCR3cBdOYgbhX19HNiGuU1rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:35509 "EHLO
	mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932155AbcFGKqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 06:46:04 -0400
Received: by mail-it0-f54.google.com with SMTP id z189so78146076itg.0
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 03:46:03 -0700 (PDT)
In-Reply-To: <CAE+=0-gQEwaAz79HoRsQGjvuTjiCR3cBdOYgbhX19HNiGuU1rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI All,
    I have a question to determine the uses of multiple loopbacks
interfaces(int loopback) in routing(quagga) on linux kernel. Please
apologise if it is a dumb question. This is what I understand, please
clarify if my understanding is correct.

1. we need them to represent a /32 ip, normally used for router-id.
2. we can measure traffic destined to that ip, via its independent
statistics per loopback interface.
3. ip unnumbered uses loopbacks to represent that ip.

my question is, is it necessary to have ifindex per loopback interface
we create? if I create kernel loopback as lo:1 (as subinterface on
default loopback in kernel) with ip assigned to it will do 1. for
getting 2 and 3 done, loopback needs to be a separate netdev. is that
correct?

Will I be having any advantage if I configure the interface as lo:1 vs
a separate netdev per loopback interface (i mean dummy netdev) to
terminate the /32 destined traffic?

Thanks in advance.
Krishna Mohan.
