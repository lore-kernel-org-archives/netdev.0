From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH  v2 03/13] Provider Methods and Data Structures
Date: Mon, 04 Dec 2006 10:50:48 -0600
Message-ID: <1165251048.32724.37.camel@stevo-desktop>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>
	 <20061202224947.27014.59189.stgit@dell3.ogc.int>
	 <1165147639.3233.211.camel@laptopd505.fenrus.org>
	 <1165249706.32724.35.camel@stevo-desktop>  <adaodqjip91.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:60864 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937119AbWLDQu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 11:50:57 -0500
To: Roland Dreier <rdreier@cisco.com>
In-Reply-To: <adaodqjip91.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-12-04 at 08:45 -0800, Roland Dreier wrote:
>  > Roland, I think at one time we were talking about changing the Core to
>  > better handle this?  Either with attributes/capabilities that the low
>  > level driver can set, or by set these method ptrs to NULL and the core
>  > should handle it in the wrapper function...
> 
> Yes, it would make sense to change the midlayer so we have different
> sets of mandatory functions for IB and iWARP drivers.  For example,
> the iwcm functions probably should be mandatory for iWARP devices, right?
> 

Yes. The iWARP devices must all support the iwcm methods for sure.



