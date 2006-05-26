From: "Majid Khan" <majidkk@gmail.com>
Subject: Netfilter and SMP
Date: Fri, 26 May 2006 11:23:37 -0400
Message-ID: <a656c20605260823o1c894411t88a76c23d7855406@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0102.google.com ([66.249.82.204]:44967 "EHLO
	wx-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1750880AbWEZPXi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 11:23:38 -0400
Received: by wx-out-0102.google.com with SMTP id h27so62703wxd
        for <netdev@vger.kernel.org>; Fri, 26 May 2006 08:23:37 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  I am developing a netfilter based application on an SMP (AMD 64;dual
core) system (kernel 2.6).
One thing that I noticed over a period of time was that most of the
network traffic was handled by only one of the processor. Only under
high network traffic (roughly 10,000 packet/sec or more) did the
second processor got invloved invloved in traffic handling. Even then
more than 90 percent of the traffic was being handled by one of the
processor.

Can somebody provide me with some information on how to configure my
SMP system so that both processors share the network traffic load.

My second question was that if there is any known method to gracefully
handle failures in a netfilter module. Currently any failure in
netfilter would cause the kernel panic.

Regards,
Majid
