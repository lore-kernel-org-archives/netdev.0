From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH V3 15/16] netfront: multi page ring
 support.
Date: Tue, 31 Jan 2012 11:15:40 +0000
Message-ID: <1328008540.5553.79.camel@leeds.uk.xensource.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	 <1327934734-8908-16-git-send-email-wei.liu2@citrix.com>
	 <20120130213926.GB16261@phenom.dumpdata.com>
	 <4F27C8240200007800070110@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:31068 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419Ab2AaLP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 06:15:27 -0500
In-Reply-To: <4F27C8240200007800070110@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-31 at 09:53 +0000, Jan Beulich wrote:
> > with more than 4GB?
> 
> Imo the use of the DMA API is a mistake here anyway. There's no need
> for anything to be contiguous in a PV frontend/backend handshake
> protocol, or if one finds there is it's very likely just because of trying to
> avoid doing something properly.
> 

Seems you're right. I look at the backend code again, I make use of 
vm_struct to create a contiguous area in backend kernel. In fact I can
avoid DMA API completely. ;-)


Wei.

> Jan
> 
