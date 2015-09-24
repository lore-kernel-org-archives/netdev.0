From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: Re: [PATCH net] lwtunnel: remove source and destination UDP port
 config option
Date: Thu, 24 Sep 2015 09:33:30 -0300
Message-ID: <20150924123329.GD10727@indiana.gru.redhat.com>
References: <340cecb5131ca28951399bf245ec37d2ca577109.1443084164.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34242 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754243AbbIXMdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 08:33:35 -0400
Content-Disposition: inline
In-Reply-To: <340cecb5131ca28951399bf245ec37d2ca577109.1443084164.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 10:43:07AM +0200, Jiri Benc wrote:
> The UDP tunnel config is asymmetric wrt. to the ports used. The source and
> destination ports from one direction of the tunnel are not related to the
> ports of the other direction. We need to be able to respond to ARP requests
> using the correct ports without involving routing.
> 
> As the consequence, UDP ports need to be fixed property of the tunnel
> interface and cannot be set per route. Remove the ability to set ports per
> route. This is still okay to do, as no kernel has been released with these
> attributes yet.
> 
> Note that the ability to specify source and destination ports is preserved
> for other users of the lwtunnel API which don't use routes for tunnel key
> specification (like openvswitch).
> 
> If in the future we rework ARP handling to allow port specification, the
> attributes can be added back.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>
> ---
> Resending what was formerly patch 2/2 of the "lwtunnel: make it really work,
> for IPv4" series, without change. This patch can be applied standalone and
> is rather important before the uAPI is set in stone.
> ---

Acked-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
