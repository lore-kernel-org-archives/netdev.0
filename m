From: Ani Sinha <ani@aristanetworks.com>
Subject: bpf filter : support for vlan tag
Date: Mon, 15 Oct 2012 19:10:15 -0700
Message-ID: <CAOxq_8MqMatY2+GA6+mHjj5V=Xe7Y8BmuX4r6cz5nChU5C1Vzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:35256 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855Ab2JPCKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 22:10:15 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so4182092iag.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 19:10:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi :

I was looking at the kernel side implementation of the BPF filter. I
do not see any code that supports filtering of packets based on
provided vlan tag information from the skbuff. This will make it
impossible to provide any filter to tcpdump that will filter packets
based on the tag information if libpcap uses the kernel filter.

Any help will be much appreciated.

Cheers,
ani
