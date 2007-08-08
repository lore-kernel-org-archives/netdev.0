From: akepner@sgi.com
Subject: Re: [PATCH 2/14] nes: device structures and defines
Date: Wed, 8 Aug 2007 09:57:30 -0700
Message-ID: <20070808165730.GA32445@sgi.com>
References: <200708080045.l780jE9E004667@neteffect.com> <200708081830.20129.mb@bu3sch.de> <46B9F054.4030000@garzik.org> <200708081843.36370.mb@bu3sch.de> <adair7qotyf.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, Jeff Garzik <jeff@garzik.org>,
	Andi Kleen <andi@firstfloor.org>, ggrundstrom@neteffect.com,
	ewg@lists.openfabrics.org, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:59570 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760002AbXHHQ6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 12:58:04 -0400
Content-Disposition: inline
In-Reply-To: <adair7qotyf.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 09:46:16AM -0700, Roland Dreier wrote:

> ....
> Not mmiowb() -- that is for ordering between CPUs, eg on systems like
> Altix where PCI transactions might get reordered in the system fabric
> before reaching the PCI bus.
> 

Yes, that's right. This is a continual source of confusion. 
FWIW, Jesse Barnes documented mmiowb() in 
Documentation/DocBook/deviceiobook.tmpl 

-- 
Arthur

