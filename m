From: John Heffner <jheffner@psc.edu>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Tue, 27 Mar 2007 20:34:18 -0400
Message-ID: <4609B80A.6070906@psc.edu>
References: <20070327214754.GA11677@dag-work> <20070327.153025.45876618.davem@davemloft.net> <4609A42A.4040304@mvista.com> <4609B680.7070601@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Huth <mhuth@mvista.com>, David Miller <davem@davemloft.net>,
	dagriego@gmail.com, netdev@vger.kernel.org
To: John Heffner <jheffner@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:62424 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934289AbXC1Ajf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 20:39:35 -0400
In-Reply-To: <4609B680.7070601@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Heffner wrote:
> I also believe this is a useful thing to have.  I'm not 100% sure this 
> ioctl is the way to go, but it seems reasonable.  This directly 
> corresponds to writing deleteTcb to the tcpConnectionState variable in 
> the TCP MIB (RFC 4022).  I don't think it constitutes a protocol violation.

Responding to myself in good form :P  I'll add that there are other ways 
to do this currently but all I know of are hackish, f.e. using a raw 
socket to send RST packets to yourself.

   -John
