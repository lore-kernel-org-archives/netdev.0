From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH v2] bonding: Make alb learning packet interval
 configurable
Date: Thu, 12 Sep 2013 17:06:13 -0400
Message-ID: <20130912210613.GA15224@gospo.rdu.redhat.com>
References: <1378822490-28667-1-git-send-email-nhorman@tuxdriver.com>
 <1378845543-14876-1-git-send-email-nhorman@tuxdriver.com>
 <20130912.164948.1364121695106020281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, vfalico@redhat.com,
	nhorman@redhat.com, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19569 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072Ab3ILVJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Sep 2013 17:09:40 -0400
Content-Disposition: inline
In-Reply-To: <20130912.164948.1364121695106020281.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 12, 2013 at 04:49:48PM -0400, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 10 Sep 2013 16:39:03 -0400
> 
> > From: Neil Horman <nhorman@redhat.com>
> > 
> > running bonding in ALB mode requires that learning packets be sent periodically,
> > so that the switch knows where to send responding traffic.  However, depending
> > on switch configuration, there may not be any need to send traffic at the
> > default rate of 3 packets per second, which represents little more than wasted
> > data.  Allow the ALB learning packet interval to be made configurable via sysfs
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> I hate to be a stickler, but I'd like you to make the default value
> documented both in the code and in the documentation.
> 
> Use some macro for the code "#define BOND_ALB_DEFAULT_LP_INTERVAL 1" and
> mention the default in the bonding.txt changes.
> 

Agree with DaveM on this.  You can just keep the one that was there and
it should be pretty easy.
