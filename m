From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: qla3xxx network driver fills the log with "Link is down" messages
Date: Tue, 21 Oct 2008 07:35:38 -0700
Message-ID: <20081021143538.GA429@susedev.qlogic.org>
References: <20081020184815.5e9ca743@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26996 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbYJURkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 13:40:51 -0400
Content-Disposition: inline
In-Reply-To: <20081020184815.5e9ca743@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2008 at 06:48:15PM -0400, Chuck Ebbert wrote:
> https://bugzilla.redhat.com/show_bug.cgi?id=461623
> 
> If you try to bring up a qla3xxx adapter without any cable connected 
> it fills the log with:
> 
> qla3xxx eth2: Link is down.
> qla3xxx eth2: port_link_state = LS_DOWN.
> qla3xxx eth2: Link is down.
> qla3xxx eth2: port_link_state = LS_DOWN.
> qla3xxx eth2: Link is down.
> qla3xxx eth2: port_link_state = LS_DOWN.
> qla3xxx eth2: Link is down.
> qla3xxx eth2: port_link_state = LS_DOWN.
> ...

Thanks for pointing this out.  I am out of town this week so will fix
this and post upstream and to distros when I return next Monday.

