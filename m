From: "Goff, Thomas" <Thomas.Goff@boeing.com>
Subject: RE: [PATCH] netlink: use the appropriate namespace pid
Date: Wed, 24 Mar 2010 07:18:12 -0700
Message-ID: <6AFD35BEDB60334C9A31FD694E13EF0D226771E62E@XCH-NW-18V.nw.nos.boeing.com>
References: <20100320013850.GA13239@boeing.com>
 	<20100321.213022.22037430.davem@davemloft.net>
 <b6fcc0a1003240058i524c95eere17c1349d14267b1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"adobriyan@openvz.org" <adobriyan@openvz.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:44299 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756381Ab0CXOSf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 10:18:35 -0400
In-Reply-To: <b6fcc0a1003240058i524c95eere17c1349d14267b1@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed March 24, 2010 12:59 AM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
> ACK tgid patch, should have sent it myself long ago.

Thanks for reviewing this.

David is correct that pid is arbitrary here anyway so it really
shouldn't matter.  The patch just lets applications that make an
incorrect assumption that happens to usually be right for the
initial namespace work similarly in other namespaces.  So
including the patch seems more of a policy question.

  Tom
