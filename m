From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Linux bridge of hsr and Ethernet interface. Is this valid?
Date: Fri, 6 Oct 2017 13:28:10 -0400
Message-ID: <e1f41460-5039-dd89-4337-701eb151f911@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:64536 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751766AbdJFR0r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 13:26:47 -0400
Received: from dflxv15.itg.ti.com ([128.247.5.124])
        by lelnx194.ext.ti.com (8.15.1/8.15.1) with ESMTP id v96HQlP5030691
        for <netdev@vger.kernel.org>; Fri, 6 Oct 2017 12:26:47 -0500
Received: from DFLE103.ent.ti.com (dfle103.ent.ti.com [10.64.6.24])
        by dflxv15.itg.ti.com (8.14.3/8.13.8) with ESMTP id v96HQlpe024867
        for <netdev@vger.kernel.org>; Fri, 6 Oct 2017 12:26:47 -0500
Received: from [158.218.103.210] (ileax41-snat.itg.ti.com [10.172.224.153])
        by dflp32.itg.ti.com (8.14.3/8.13.8) with ESMTP id v96HQkC0017912
        for <netdev@vger.kernel.org>; Fri, 6 Oct 2017 12:26:47 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Linux netdev experts,

I have a board that has multiple Ethernet intefaces. two, eth0 and eth1 and 1G interfaces and two are 100M interfaces (eth2 and eth3). I create  hsr interface, hsr0 using eth2 and eth3 using ip link command. Now I want to create a linux bridge as follows:-

brctl addbr my_bridge
brctl addif eth0
brctl addif hsr0

I connect a PC to eth0 interface and another hsr compliant device to eth2 or eth3. Is it a valid scenario? 


I see following description at https://wiki.linuxfoundation.org/networking/bridge where is mentioned that 

=============================
Adding devices to a bridge

The command

 brctl addif //bridgename// //device//

adds the network device device to take part in the bridging of “bridgename.” All the devices contained in a bridge act as one big network. It is not possible to add a device to multiple bridges or bridge a bridge device, because it just wouldn't make any sense! The bridge will take a short amount of time when a device is added to learn the Ethernet addresses on the segment before starting to forward. 

=============================

In this case hsr is already a 802.1D bridge and we are trying to bridge a bridge.

So your expert opinion is needed. Thanks.
-- 
Murali Karicheri
Linux Kernel, Keystone
