From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 12:07:09 +0100
Message-ID: <201201191207.10207.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:58510 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750831Ab2ASLHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 06:07:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Closing of a namespace (container) can be delayed by ~ 2 minutes 
due to tcp timers ex tcp time wait (and of cource other things too).

I think there should be some kind of "forced close" of the Network stack
in ex free_nsproxy() 

A netns pre-close  callback might do the job....

Any ideas how to solve this ?

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
