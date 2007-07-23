From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH] make xfrm_audit_log more generic
Date: Mon, 23 Jul 2007 12:49:17 -0500
Message-ID: <1185212957.15699.322.camel@faith.austin.ibm.com>
References: <200707192242.l6JMglVk029578@faith.austin.ibm.com>
	 <Line.LNX.4.64.0707192140350.12692@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-audit@redhat.com, sgrubb@redhat.com
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:38526 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760966AbXGWRvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 13:51:23 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6NHpMfK006948
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 13:51:22 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6NHpMHm228992
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 11:51:22 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6NHpMdS012166
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 11:51:22 -0600
In-Reply-To: <Line.LNX.4.64.0707192140350.12692@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-19 at 21:45 -0400, James Morris wrote:
> On Thu, 19 Jul 2007, Joy Latten wrote:
> 
> > --- linux-2.6.22/include/linux/audit.h	2007-07-19 13:17:22.000000000 -0500
> > +++ linux-2.6.22.patch/include/linux/audit.h	2007-07-19 13:21:29.000000000 -0500
> > @@ -108,10 +108,7 @@
> >  #define AUDIT_MAC_CIPSOV4_DEL	1408	/* NetLabel: del CIPSOv4 DOI entry */
> >  #define AUDIT_MAC_MAP_ADD	1409	/* NetLabel: add LSM domain mapping */
> >  #define AUDIT_MAC_MAP_DEL	1410	/* NetLabel: del LSM domain mapping */
> > -#define AUDIT_MAC_IPSEC_ADDSA	1411	/* Add a XFRM state */
> > -#define AUDIT_MAC_IPSEC_DELSA	1412	/* Delete a XFRM state */
> > -#define AUDIT_MAC_IPSEC_ADDSPD	1413	/* Add a XFRM policy */
> > -#define AUDIT_MAC_IPSEC_DELSPD	1414	/* Delete a XFRM policy */
> > +#define AUDIT_MAC_IPSEC_EVENT	1411	/* Audit IPSec events */
> 
> Will this cause existing applications to break?
> 

Perhaps someone in audit list could help answer this. 

During testing, because I changed the above defines, all
IPSec events are listed as "MAC_IPSEC_ADDSA" for now without
userspace change. Is this ok? Or is there a better way to 
migrate this change in? Perhaps leave previous IPsec defines 
and just add in a new one and use it? If that is better
approach, let me know and I will change code to accomodate.

Regards,
Joy
 
