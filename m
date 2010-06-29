From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH 0/9] New cxgb4vf network driver for Chelsio T4 Virtual Function NIC
Date: Tue, 29 Jun 2010 16:02:04 -0700
Message-ID: <201006291602.04663.leedom@chelsio.com>
References: <201006251507.48604.leedom@chelsio.com> <20100629.000142.52193526.davem@davemloft.net> <201006290904.50370.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20428 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab0F2XKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 19:10:41 -0400
In-Reply-To: <201006290904.50370.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: Casey Leedom <leedom@chelsio.com>
| Date: Tuesday, June 29, 2010 09:04 am
| 
|   Thank you and I'm sorry for the mess. (sigh) I'm using the Kubuntu
| supplied email client and I mistakenly assumed that its "Insert File"
| action would do the right job.  I'll just use Thunderbird from now on.

  Hopefully my latest effort at getting patches submitted will be better.  
There's evidently a way to get git to mail them directly with which I'm fighting, 
so in the mean time I disabled word wrap on my current mailer.  I will get 
someone here to help me out with the git (and stgit) patch support.

|   Odd that patch #3 didn't apply cleanly.  I'll do a "pull" and verify
| correct operation.

  I did a complete new pull, compared the submitted and the pulled source and 
found no differences.  I then did a thorough test run and discovered that I'd 
accidentally translated one of our internal symbolic names into the wrong 
kernel.org symbolic names.  By "luck" it worked for some packet sizes so I 
didn't catch it. (sigh)  I've submitted patches for that bug and the deletion of 
an obsolete comment which I forgot to get rid of earlier.

  I hope these new patches apply cleanly.  If not, just drop them and I'll got 
to remedial git school here and get someone to help me do it right.

Casey
