From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: setsockopt(IP_TOS) being privileged or distinct capability?
Date: Tue, 6 Jul 2010 04:07:34 +0200
Message-ID: <20100706020734.GA2972@nuttenaction>
References: <4C2F7A55.5090700@redfish-solutions.com>
 <2md4g7-3s3.ln1@chipmunk.wormnet.eu>
 <4C2FC2C8.8080203@redfish-solutions.com>
 <20100703234813.GJ24655@chipmunk>
 <4C321EAF.9000508@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Clouter <alex@digriz.org.uk>, netdev@vger.kernel.org
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:42731 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756709Ab0GFCHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:07:38 -0400
Content-Disposition: inline
In-Reply-To: <4C321EAF.9000508@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Philip Prindeville | 2010-07-05 12:04:31 [-0600]:

>I understand that.  That's part of the reason that I've submitted
>patches for APR, Apache, Thunderbird, Firefox, Proftpd, Curl, wget,
>etc.  There is pressure within certain technical groups to get ISP's
>to voluntarily implement RFC-4594... that's the carrot.  The stick
>being FCC heavy-handed regulation of the ISP's if they don't.

Where is the _real_ advantage if setsockopt(IP_TOS) where a privileged
operation? At the end the user/service is still required to set his service
class, but this time with CAP_NET_ADMIN. Do you think that Service
Providers/Transit Providers trust (and this is the critical aspect) customers
based on some IP flags - this is extreme unlikely. 99% of users have
effective CAP_NET_ADMIN capabilities - and you cannot stop using them.

Service Providers/Transit Providers will trust customers who pays more and
then they will accept their DIFFSERV suggestion signaled via IP DSCP. All
other customers will be treated normal, with zeroed DSCP. It makes no sense
for ISP's to shift the trust aspect to the customer side.

HGN




