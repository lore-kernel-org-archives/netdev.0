From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: Network drivers that don't suspend on interface down
Date: Thu, 21 Dec 2006 02:20:53 +0000
Message-ID: <20061221022053.GB723@srcf.ucam.org>
References: <20061219185223.GA13256@srcf.ucam.org> <1166638371.2798.26.camel@localhost.localdomain> <20061221011526.GB32625@srcf.ucam.org> <200612202057.09545.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, Jiri Benc <jbenc@suse.cz>,
	Arjan van de Ven <arjan@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([217.147.92.49]:46325 "EHLO
	vavatch.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161144AbWLUCVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 21:21:09 -0500
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200612202057.09545.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 20, 2006 at 08:57:05PM -0500, Michael Wu wrote:

(allowing scanning while the interface is down)

> No, it's absolutely a bug. It just so happens that some drivers incorrectly 
> allowed it.

Ok. Would it be reasonable to add warnings to any devices that allow it?
-- 
Matthew Garrett | mjg59@srcf.ucam.org
