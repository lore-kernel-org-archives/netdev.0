From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: [Xen-devel] [PATCH 0/4] [Net] Support Xen accelerated network
	plugin modules
Date: Mon, 21 May 2007 11:28:45 +0100
Message-ID: <1179743325.4118.20.camel@moonstone.uk.level5networks.com>
References: <1179494148.14376.7.camel@moonstone.uk.level5networks.com>
	 <fdaac4d50705210302q7533227bkfc302aa9cee901b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, muli@il.ibm.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: Jun Koi <junkoi2004@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:37768 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756414AbXEUK2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 06:28:49 -0400
In-Reply-To: <fdaac4d50705210302q7533227bkfc302aa9cee901b5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-21 at 19:02 +0900, Jun Koi wrote:
> On 5/18/07, Kieran Mansley <kmansley@solarflare.com> wrote:
> > This set of patches provides the hooks and support necessary for
> > accelerated network plugin modules to attach to Xen's netback and
> > netfront.  These modules provide a fast path for network traffic where
> > there is hardware support available for the netfront driver to send and
> > receive packets directly to a NIC (such as those available from
> > Solarflare).
> >
> 
> Hi Kieran,
> 
> This is interesting. Just a question: is this possible for more than 1
> domain to access directly to NIC, or at a time only 1 domain can do
> that?

Many domains can directly access the NIC at the same time.  The number
of virtual interfaces that can be created would depend on what NIC
hardware you're using.  

Kieran

