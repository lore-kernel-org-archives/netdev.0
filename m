From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] make xfrm_audit_log more generic
Date: Thu, 19 Jul 2007 21:45:45 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707192140350.12692@d.namei>
References: <200707192242.l6JMglVk029578@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-audit@redhat.com, sgrubb@redhat.com
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:43010 "EHLO
	mail1.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbXGTBpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 21:45:47 -0400
In-Reply-To: <200707192242.l6JMglVk029578@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Jul 2007, Joy Latten wrote:

> --- linux-2.6.22/include/linux/audit.h	2007-07-19 13:17:22.000000000 -0500
> +++ linux-2.6.22.patch/include/linux/audit.h	2007-07-19 13:21:29.000000000 -0500
> @@ -108,10 +108,7 @@
>  #define AUDIT_MAC_CIPSOV4_DEL	1408	/* NetLabel: del CIPSOv4 DOI entry */
>  #define AUDIT_MAC_MAP_ADD	1409	/* NetLabel: add LSM domain mapping */
>  #define AUDIT_MAC_MAP_DEL	1410	/* NetLabel: del LSM domain mapping */
> -#define AUDIT_MAC_IPSEC_ADDSA	1411	/* Add a XFRM state */
> -#define AUDIT_MAC_IPSEC_DELSA	1412	/* Delete a XFRM state */
> -#define AUDIT_MAC_IPSEC_ADDSPD	1413	/* Add a XFRM policy */
> -#define AUDIT_MAC_IPSEC_DELSPD	1414	/* Delete a XFRM policy */
> +#define AUDIT_MAC_IPSEC_EVENT	1411	/* Audit IPSec events */

Will this cause existing applications to break?




- James
-- 
James Morris
<jmorris@namei.org>
