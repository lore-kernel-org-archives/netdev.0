From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 00/05]IPtablestng/UserSpace-user part of iptablestng
Date: Mon, 27 Oct 2008 09:07:56 +0330 (IRST)
Message-ID: <20081027053756.157E5C64097@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

some modification at user land to work with New Framework For IPtables

it 's for iptables-1.4.1
libiptc.c is rewrote from scrach to work with new framework.  and also some modifications for cammands to be aware of classifier.
new command for iptables: -C 
	iptables -C INPUT tuple
	:change the classifier of INPUT chain
