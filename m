From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [Fwd: [PATCH] [TIPC]: Enhancements to msg_set_bits() routine]
Date: Fri, 27 Apr 2007 13:06:16 +0200
Message-ID: <200704271306.17480.netdev@axxeo.de>
References: <462E52DE.5000900@ericsson.com> <200704251839.44056.netdev@axxeo.de> <462FBADA.2060701@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jon Paul Maloy <jon.maloy@ericsson.com>,
	Per Liden <per.liden@ericsson.com>,
	"Stephens, Allan" <allan.stephens@windriver.com>
To: Jon Paul Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:42374 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755600AbXD0LG0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 07:06:26 -0400
In-Reply-To: <462FBADA.2060701@ericsson.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jon,

Jon Paul Maloy schrieb:
> Ingo Oeser wrote:
> > static inlinevoid msg_set_bits(struct tipc_msg *m, u32 w,
> >   				u32 pos, __be32 mask, __be32 val)
> >
> >
> > Care to resubmit?

> I don't mind at all, but I would first like to understand better
> what this means. 
> If I understand it correctly __be32 literally means "big-endian
> 32-bit integer", but the way it is used doesn't seem to imply this,
> since both input and output to htonl() often is of that type.

Yes, you are right! I mixed up htonl and ntohl :-)
Sorry for the confusion!

Best Regards

Ingo Oeser
