From: David Miller <davem@davemloft.net>
Subject: Re: vxlan gso is broken by stackable gso_segment()
Date: Fri, 25 Oct 2013 19:10:59 -0400 (EDT)
Message-ID: <20131025.191059.1462456656717647875.davem@davemloft.net>
References: <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	<20131025.181809.348808013109842304.davem@davemloft.net>
	<CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366Ab3JYXLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:11:01 -0400
In-Reply-To: <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 25 Oct 2013 15:41:47 -0700

> 'bool tunnel' actually still used to indicate encap_level > 0

Good catch, I misread the code.
