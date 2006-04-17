From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] Geographical/regulatory information for ieee80211
Date: Mon, 17 Apr 2006 10:55:32 -0700
Message-ID: <4443D694.8090809@hp.com>
References: <443EF3E9.7050303@lwfinger.net> <20060415174734.GA10595@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	jeffl@comix.santa-cruz.ca.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:53225 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1751191AbWDQRzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 13:55:35 -0400
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060415174734.GA10595@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Thu, Apr 13, 2006 at 07:59:21PM -0500, Larry Finger wrote:
> 
>>I am planning on writing a new routine to be added to 
>>net/ieee80211/ieee80211_geo.c that will populate an ieee80211_geo object 
>>given a country code. The new routine will eliminate the need for each 
>>driver to do their own.
> 
> 
> This sounds like a generally good idea, but the question is:  do we want
> this inside a kernel module or in userspace, either like the regulartory
> daemon intel has (unfortunately in binary only form) or as a simple init
> script.  I really don't want to recompile my kernel just because regulations
> changed, and they seems to do that quite often.

Yet I would expect the regulatory bodies to look less favorably on 
something more easily maleable by the end-user.

rick jones
