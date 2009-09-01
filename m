From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 16:13:49 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909011613060.12112@V090114053VZO-1>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net> <4A9D3687.2020101@gmail.com> <alpine.DEB.1.10.0909011504030.12112@V090114053VZO-1> <4A9D3D9A.1030500@gmail.com>
 <alpine.DEB.1.10.0909011534350.12112@V090114053VZO-1> <4A9D410D.5000507@gmail.com> <4A9D448D.6050309@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:52985 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751850AbZIAQOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 12:14:54 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0955782C253
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 12:16:32 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Bf6Yeoh3FYQb for <netdev@vger.kernel.org>;
	Tue,  1 Sep 2009 12:16:31 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 425ED82C441
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 12:16:03 -0400 (EDT)
In-Reply-To: <4A9D448D.6050309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2009, Eric Dumazet wrote:

> For your multicast test anyway, only one queue should be used (one flow)

Right.

I finally get some numbers with the qdisc_stats patch:

clameter@rd-strategy3-deb64:~$ cat /proc/net/qdisc_stats
Type     Device St  Bytes    Packts Qlen Bklg Drops  Requeu Overlimits
TXS root <NULL>   0        0      0    0    0      0      0      0
TX root <NULL>   0        0      0    0    0      0      0      0
RXS root <NULL>   0        0      0    0    0      0      0      0
RX root <NULL>   0        0      0    0    0      0      0      0
TXS root   eth0   0     2778     35    0    0      0      0      0
TX root   eth0   0     2778     35    0    0      0      0      0
TXS root   eth0   0     1622     18    0    0      0      0      0
TX root   eth0   0     1622     18    0    0      0      0      0
TXS root   eth0   0     2618     22    0    0      0      0      0
TX root   eth0   0     2618     22    0    0      0      0      0
TXS root   eth0   0     9792     65    0    0      0      0      0
TX root   eth0   0     9792     65    0    0      0      0      0
TXS root   eth0   0     9758     68    0    0      0      0      0
TX root   eth0   0     9758     68    0    0      0      0      0
TXS root   eth0   0     1413     18    0    0      0      0      0
TX root   eth0   0     1413     18    0    0      0      0      0
TXS root   eth0   0      557      8    0    0      0      0      0
TX root   eth0   0      557      8    0    0      0      0      0
TXS root   eth0   0     1220     11    0    0      0      0      0
TX root   eth0   0     1220     11    0    0      0      0      0
RXS root <NULL>   0        0      0    0    0      0      0      0

