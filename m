From: "Martin J. Bligh" <mbligh@google.com>
Subject: Strange errors from e1000 driver (2.6.18)
Date: Sun, 22 Oct 2006 11:46:54 -0700
Message-ID: <453BBC9E.4040300@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:55373 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1750773AbWJVSs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Oct 2006 14:48:58 -0400
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm getting a lot of these type of errors if I run 2.6.18. If
I run the standard Ubuntu Dapper kernel, I don't get them.
What do they indicate?

Oct 21 18:48:28 localhost kernel: buffer_info[next_to_clean]
Oct 21 18:48:28 localhost kernel:   time_stamp           <7b79d33>
Oct 21 18:48:28 localhost kernel:   next_to_watch        <3d>
Oct 21 18:48:28 localhost kernel:   jiffies              <7b7a0c1>
Oct 21 18:48:28 localhost kernel:   next_to_watch.status <0>
Oct 21 18:48:30 localhost kernel:   Tx Queue             <0>
Oct 21 18:48:30 localhost kernel:   TDH                  <3d>
Oct 21 18:48:30 localhost kernel:   TDT                  <44>
Oct 21 18:48:30 localhost kernel:   next_to_use          <44>
Oct 21 18:48:30 localhost kernel:   next_to_clean        <39>
Oct 21 18:48:30 localhost kernel: buffer_info[next_to_clean]
Oct 21 18:48:30 localhost kernel:   time_stamp           <7b79d33>
Oct 21 18:48:30 localhost kernel:   next_to_watch        <3d>
Oct 21 18:48:30 localhost kernel:   jiffies              <7b7a2b5>
Oct 21 18:48:30 localhost kernel:   next_to_watch.status <0>
Oct 21 18:48:32 localhost kernel:   Tx Queue             <0>
Oct 21 18:48:32 localhost kernel:   TDH                  <3d>
Oct 21 18:48:32 localhost kernel:   TDT                  <44>
Oct 21 18:48:32 localhost kernel:   next_to_use          <44>
Oct 21 18:48:32 localhost kernel:   next_to_clean        <39>
Oct 21 18:48:32 localhost kernel: buffer_info[next_to_clean]
Oct 21 18:48:32 localhost kernel:   time_stamp           <7b79d33>
Oct 21 18:48:32 localhost kernel:   next_to_watch        <3d>
Oct 21 18:48:32 localhost kernel:   jiffies              <7b7a4a9>
Oct 21 18:48:32 localhost kernel:   next_to_watch.status <0>
Oct 21 18:48:34 localhost kernel:   Tx Queue             <0>
Oct 21 18:48:34 localhost kernel:   TDH                  <3d>
Oct 21 18:48:34 localhost kernel:   TDT                  <44>
Oct 21 18:48:34 localhost kernel:   next_to_use          <44>
Oct 21 18:48:34 localhost kernel:   next_to_clean        <39>
Oct 21 18:48:34 localhost kernel: buffer_info[next_to_clean]
Oct 21 18:48:34 localhost kernel:   time_stamp           <7b79d33>
Oct 21 18:48:34 localhost kernel:   next_to_watch        <3d>
Oct 21 18:48:34 localhost kernel:   jiffies              <7b7a69d>
Oct 21 18:48:34 localhost kernel:   next_to_watch.status <0>
Oct 21 18:48:35 localhost kernel: NETDEV WATCHDOG: eth0: transmit timed out
Oct 21 18:48:36 localhost kernel: e1000: eth0: e1000_watchdog: NIC Link 
is Up 100 Mbps Full Duplex
