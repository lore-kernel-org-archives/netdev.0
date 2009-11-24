From: Caleb Cushing <xenoterracide@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Tue, 24 Nov 2009 01:17:09 -0500
Message-ID: <81bfc67a0911232217n41b9ac02w3b7770b789e5d209@mail.gmail.com>
References: <81bfc67a0911120546g26627ac5q5860d85f446b29bb@mail.gmail.com>
	 <81bfc67a0911130825o6d9b93b2he70677157ad889f2@mail.gmail.com>
	 <20091113211640.GA2540@ami.dom.local>
	 <81bfc67a0911180159g45a45675k44ce3f251c6bddea@mail.gmail.com>
	 <20091118135136.GA9224@ff.dom.local>
	 <81bfc67a0911181021n1b969565y4a39b181360b5e92@mail.gmail.com>
	 <20091118201034.GA3060@ami.dom.local>
	 <20091118223851.GA5191@ami.dom.local>
	 <81bfc67a0911221135y300841f2i8e78417600528cd5@mail.gmail.com>
	 <20091122205054.GA7361@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:62526 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920AbZKXGRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 01:17:04 -0500
In-Reply-To: <20091122205054.GA7361@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Btw, currently I don't consider this dropping means there has to be
> a bug. It could be otherwise - a feature... e.g. when a new kernel
> can transmit faster (then dropping in some other, slower place can
> happen).

um... where would it be dropping that we wouldn't have a bug? I mean
sure faster is great... but if it makes my network not work right...

I've added all (I think) information you've asked for to the bug
http://bugzilla.kernel.org/show_bug.cgi?id=13835 except for ethtool
and netstat on the router side. ethtool complains about not having
driver or capability (maybe because it's a 2.4 kernel?) and the
version of netstat doesn't support -s. I disabled everything that I
can think of that would send/receive packets before doing the test
client side, except dhcp/dns windows box's were probably sending some
broadcasts too. but the traffic should be pretty low. I did remember
to set the txqueuelen didn't seem to make a difference

only error in dmesg I see is

e1000e 0000:00:19.0: pci_enable_pcie_error_reporting failed 0xfffffffb

but it's in working versions too.
-- 
Caleb Cushing

http://xenoterracide.blogspot.com
