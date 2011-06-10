From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 3/5 net-next] cnic: Randomize initial TCP port for
 iSCSI connections
Date: Thu, 9 Jun 2011 23:25:12 -0700
Message-ID: <C27F8246C663564A84BB7AB343977242667C64F9B7@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
 <1307597376-5379-2-git-send-email-mchan@broadcom.com>
 <1307597376-5379-3-git-send-email-mchan@broadcom.com>
 <20110609082722.492b46b5@nehalam.ftrdhcpuser.net>
 <1307668080.14980.13.camel@HP1>
 <20110609210157.6a1f016b@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'davem@davemloft.net'" <davem@davemloft.net>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"Eddie Wai" <eddie.wai@broadcom.com>
To: "'Stephen Hemminger'" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4666 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130Ab1FJGZ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 02:25:28 -0400
In-Reply-To: <20110609210157.6a1f016b@nehalam.ftrdhcpuser.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

> On Thu, 9 Jun 2011 18:08:00 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
> > random32() is pseudo random so we can get the same number after reboot,
> > right?  One scenario is that we may be booting from an iSCSI target, but
> > due to some failure, the user may be rebooting multiple times rapidly.
> > We want to use a different port during each boot.
> 
> random32 is seeded off get_random_bytes at boot.

Thanks.  We'll change it to random32() in our next patchset then.

