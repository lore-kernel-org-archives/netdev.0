From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [ofa-general] Re: [PATCH v3 01/13] QLogic VNIC: Driver - netdev
 implementation
Date: Tue, 3 Jun 2008 10:51:24 -0700
Message-ID: <20080603105124.2f663297@extreme>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	<20080529095423.9943.77528.stgit@localhost.localdomain>
	<20080529102752.584147ee@extreme>
	<71d336490806030514k580418e3n23790eb793e99381@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com,
	amar.mudrankit@qlogic.com, general@lists.openfabrics.org,
	poornima.kamath@qlogic.com
To: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:36699 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756575AbYFCRv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 13:51:26 -0400
In-Reply-To: <71d336490806030514k580418e3n23790eb793e99381@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 3 Jun 2008 17:44:23 +0530
"Ramachandra K" <ramachandra.kuchimanchi@qlogic.com> wrote:

> On Thu, May 29, 2008 at 10:57 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > On Thu, 29 May 2008 15:24:23 +0530
> > Ramachandra K <ramachandra.kuchimanchi@qlogic.com> wrote:
> 
> <snip>
> >
> >> +module_param(vnic_debug, uint, 0444);
> >> +MODULE_PARM_DESC(vnic_debug, "Enable debug tracing if > 0");
> >
> > maybe migrate this to ethtool msg_level?
> >
> 
> We investigated this and found that we cannot map all of our Infiniband
> level communication errors etc to the ethtool message levels. One option could
> be to add support for Ethtool message levels in addition to the vnic_debug
> controlled messages. The Ethtool support would make this driver conform
> to ethtool similar to other Ethernet drivers and the vnic_debug messages will
> help in debugging the Infiniband related errors.
> 
> Is ethtool support mandatory for a merge to 2.6.27 or can we consider
> it as a future
> enhancement while we first focus on moving this driver to use CONFIGFS ?
> 
> Regards,
> Ram

No problem, just a suggestion of how to make it easier to manage.
