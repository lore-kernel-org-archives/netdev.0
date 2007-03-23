From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/1][PKT_CLS] Avoid multiple tree locks
Date: Fri, 23 Mar 2007 09:12:58 -0400
Message-ID: <1174655578.4930.12.camel@localhost>
References: <1174471116.16343.10.camel@localhost>
	 <4601047A.6050108@trash.net> <46010641.3000009@trash.net>
	 <4601268D.7090003@trash.net>  <46013B73.2060804@trash.net>
	 <1174543640.4895.28.camel@localhost>  <46026A31.1090603@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.249]:32822 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933749AbXCWNNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:13:04 -0400
Received: by an-out-0708.google.com with SMTP id b33so1342801ana
        for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 06:13:02 -0700 (PDT)
In-Reply-To: <46026A31.1090603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-22-03 at 12:36 +0100, Patrick McHardy wrote:
> jamal wrote:
> > On Wed, 2007-21-03 at 15:04 +0100, Patrick McHardy wrote:

> We can remove qdisc_tree_lock since with this patch all changes
> and all tree walking happen under the RTNL. 
> We still need to keep dev->queue_lock for the data path.
> 

ok, that would work. Should have been obvious to me.

cheers,
jamal

