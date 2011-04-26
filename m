From: zhou rui <zhourui.cn@gmail.com>
Subject: how to set vlan filter for intel 82599
Date: Tue, 26 Apr 2011 10:19:23 +0800
Message-ID: <BANLkTikZcdda5-3NBaXyKmij09f62Da3cQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:45710 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932826Ab1DZCTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 22:19:23 -0400
Received: by iwn34 with SMTP id 34so160228iwn.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 19:19:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi
here is the problem troubles me,how to set vlan filter for intel
82599? for example
I want vlan id 0~31 will go to queue 0, vlan id 32-63 will go to queue
1...below is my setting,but doesn't work

don't know the exact meanning of the vlan-mask and vlan,how are they calculated?

./ethtool -K eth5 ntuple on

./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-ip 0x0
dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
dst-port-mask 0x0 vlan 0x0000 vlan-mask 0x00E0 user-def 0x0
user-def-mask 0x0 action 0
./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-ip 0x0
dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
dst-port-mask 0x0 vlan 0x0020 vlan-mask 0x00E0 user-def 0x0
user-def-mask 0x0 action 1
./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-ip 0x0
dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
dst-port-mask 0x0 vlan 0x0040 vlan-mask 0x00E0 user-def 0x0
user-def-mask 0x0 action 2
./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-ip 0x0
dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
dst-port-mask 0x0 vlan 0x0060 vlan-mask 0x00E0 user-def 0x0
user-def-mask 0x0 action 3
./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-ip 0x0
dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
dst-port-mask 0x0 vlan 0x0080 vlan-mask 0x00E0 user-def 0x0
user-def-mask 0x0 action 4
./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-ip 0x0
dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
dst-port-mask 0x0 vlan 0x00A0 vlan-mask 0x00E0 user-def 0x0
user-def-mask 0x0 action 5
./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-ip 0x0
dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
dst-port-mask 0x0 vlan 0x00C0 vlan-mask 0x00E0 user-def 0x0
user-def-mask 0x0 action 6
./ethtool -U eth5 flow-type udp4 src-ip 0x0 src-ip-mask 0x0 dst-ip 0x0
dst-ip-mask 0x0 src-port 0x0 src-port-mask 0x0 dst-port 0x0
dst-port-mask 0x0 vlan 0x00E0 vlan-mask 0x00E0 user-def 0x0
user-def-mask 0x0 action 6

thanks
rui
