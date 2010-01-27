From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: Network QoS support in applications
Date: Wed, 27 Jan 2010 09:57:51 +0800
Message-ID: <1264557471.5282.24.camel@debian>
References: <877hr5nkx0.fsf@purkki.valot.fi>
	 <20100126.041610.226004766.davem@davemloft.net>
	 <87wrz5m3cd.fsf@purkki.valot.fi>
	 <20100126.050645.184040277.davem@davemloft.net>
	 <87my01m0zm.fsf@purkki.valot.fi>  <4B5EF5DF.2070005@lemonia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kalle.valo@iki.fi>, David Miller <davem@davemloft.net>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Dunc <dunc@lemonia.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18962 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754445Ab0A0B5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2010 20:57:45 -0500
In-Reply-To: <4B5EF5DF.2070005@lemonia.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-26 at 22:02 +0800, Dunc wrote:
> If applications set the QoS values, the who's to stop someone (for
> example) writing a bittorrent client that marks all packets for the
> highest priority as if they were VoIP or something? At this point all
> the good work done in the applications is useless and the network
> admin is going to have to not trust the QoS values and then attempt to
> classify traffic by themselves, so it was all a waste of time.

The QoS values an application sets can be viewed as "hints". It is still
the network admin's choice to use it or not. For example, as a network
admin for an Internet router, you don't want to trust any QoS values
from ingress. But as a smart phone owner, you probably want to trust the
applications running on it. For end users on noncritical devices,
requiring them to do traffic mapping themselves is too much. IMO, having
a way for the applications to specify the traffic priority they _wish_
to have is useful.

Thanks,
-yi

