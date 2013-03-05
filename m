From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 2/8] netback: add module unload function
Date: Tue, 5 Mar 2013 13:30:01 +0000
Message-ID: <1362490201.4748.21.camel@zion.uk.xensource.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
	 <1360944010-15336-3-git-send-email-wei.liu2@citrix.com>
	 <20130304135831.4d52eddc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:28571 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754886Ab3CENaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 08:30:04 -0500
In-Reply-To: <20130304135831.4d52eddc@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-04 at 21:58 +0000, Stephen Hemminger wrote:
> On Fri, 15 Feb 2013 16:00:03 +0000
> Wei Liu <wei.liu2@citrix.com> wrote:
> 
> > Enable users to unload netback module. Users should make sure there is not vif
> > runnig.
> 
> 
> Isn't it likely that some admin might be trying to cleanup or do shutdown and there
> is an ordering problem. What happens if vif's are still running?
> 
> Why depend on users? You should allow it anytime and do refcounting and auto-destroy the vif's for them.

Sure, we should not depend on users. I will move my vif get/put module
patch before this one.


Wei.
