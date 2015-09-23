From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 2/2] lwtunnel: remove source and destination UDP port
 config option
Date: Wed, 23 Sep 2015 10:12:41 +0200
Message-ID: <20150923081241.GD29680@pox.localdomain>
References: <cover.1442936392.git.jbenc@redhat.com>
 <f962835d846498c2d548bbd1192ee42a96742be4.1442936392.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:32862 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbbIWIMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 04:12:44 -0400
Received: by wiclk2 with SMTP id lk2so227151364wic.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 01:12:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <f962835d846498c2d548bbd1192ee42a96742be4.1442936392.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/15 at 06:12pm, Jiri Benc wrote:
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

Acked-by: Thomas Graf <tgraf@suug.ch>
