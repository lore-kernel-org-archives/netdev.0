From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: sysfs vs. d80211 configuration
Date: Tue, 15 Aug 2006 09:41:09 +0200
Message-ID: <44E17A95.2040006@sipsolutions.net>
References: <44E07662.8070506@sipsolutions.net> <Pine.NEB.4.64.0608142302560.21364@otaku.freeshell.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:25227 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965262AbWHOHlN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 03:41:13 -0400
To: Alexey Toptygin <alexeyt@freeshell.org>
In-Reply-To: <Pine.NEB.4.64.0608142302560.21364@otaku.freeshell.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Toptygin wrote:
> Why not have the tool create a monitor interface, open it, and fork; 
> the child drops privileges and does the reading, and the parent 
> wait(2)s for the child and removes the interface once it has collected 
> the child?
Good point, that'll work. Then again, I want this to run on really tiny 
architectures and I'm thinking some of them might not have fork(), just 
vfork(). Hmm.

johannes
