From: Dave Jones <davej@redhat.com>
Subject: Re: [RFC] ehea: kdump support using new shutdown hook
Date: Wed, 12 Dec 2007 12:04:40 -0500
Message-ID: <20071212170440.GD2359@redhat.com>
References: <200712121753.43543.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Michael Ellermann <michael@ellerman.id.au>,
	Michael Neuling <mikey@neuling.org>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45735 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753825AbXLLREy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 12:04:54 -0500
Content-Disposition: inline
In-Reply-To: <200712121753.43543.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2007 at 05:53:43PM +0100, Thomas Klein wrote:

 > +static void ehea_update_adapter_handles(struct ehea_adapter *adapter)
 > +{
 > +	int i, k;
 > +	int j = 0;
 > +
 > +	memset(adapter->res_handles, sizeof(adapter->res_handles), 0);

arguments wrong way around.
 
	Dave
 
-- 
http://www.codemonkey.org.uk
