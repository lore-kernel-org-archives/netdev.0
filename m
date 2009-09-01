From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 15:35:19 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909011534350.12112@V090114053VZO-1>
References: <20090901063726.GA5222@ff.dom.local> <alpine.DEB.1.10.0909011358030.15578@V090114053VZO-1> <4A9D2DBF.8030200@trash.net> <4A9D3687.2020101@gmail.com> <alpine.DEB.1.10.0909011504030.12112@V090114053VZO-1> <4A9D3D9A.1030500@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:60258 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754632AbZIAPhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:37:16 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 01FE882C45F
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 11:38:55 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wIBWjXQeG1Sc for <netdev@vger.kernel.org>;
	Tue,  1 Sep 2009 11:38:54 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 823ED82C787
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 11:37:32 -0400 (EDT)
In-Reply-To: <4A9D3D9A.1030500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Sep 2009, Eric Dumazet wrote:

> You should see that in /proc/interrupts, if I correctly understand bnx2.c

Hmmm I have 8 interrupts:

  62:        158          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0  IR-PCI-MSI-edge      eth0-0
  63:         84          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0  IR-PCI-MSI-edge      eth0-1
  64:        412          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0  IR-PCI-MSI-edge      eth0-2
  65:         25          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0  IR-PCI-MSI-edge      eth0-3
  66:      49718          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0  IR-PCI-MSI-edge      eth0-4
  67:         65          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0  IR-PCI-MSI-edge      eth0-5
  68:        686          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0  IR-PCI-MSI-edge      eth0-6
  69:       2582          0          0          0          0          0
0          0          0          0          0          0          0
0          0          0  IR-PCI-MSI-edge      eth0-7
