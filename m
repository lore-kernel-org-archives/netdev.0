From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Problem with vlan bridge
Date: Mon, 10 Jun 2013 02:23:14 +0000 (UTC)
Message-ID: <kp3dai$2h5$1@ger.gmane.org>
References: <loom.20130530T080452-121@post.gmane.org>
 <loom.20130601T085324-570@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:56317 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431Ab3FJCXe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 22:23:34 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Ulrlc-0004So-NR
	for netdev@vger.kernel.org; Mon, 10 Jun 2013 04:23:32 +0200
Received: from 112.116.154.100 ([112.116.154.100])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 04:23:32 +0200
Received: from xiyou.wangcong by 112.116.154.100 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 04:23:32 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 01 Jun 2013 at 07:02 GMT, kermani <somayeh.kermani@gmail.com> wrote:
> Molaei <zohrehmolaei <at> gmail.com> writes:
>
>> 
>> i have fedora 19 with kernel 3.9 and want to use iproute for adding vlan
>> bridge. i do this configuration but vlan bridge not work.
>> 
...
>> 
>> when i sen broadcast message from systemtha connected to eth0, systam
>> connected to eth1 get broadcast message with vid 200.
>> 
>
> I have same problem and configuration is as a follow:
>

Did you set /sys/class/net/br0/bridge/vlan_filtering to 1? It is 0 by
default, and this is expected behavior if it is 0.
