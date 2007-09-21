From: jamal <hadi@cyberus.ca>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 09:46:06 -0400
Message-ID: <1190382366.4231.13.camel@localhost>
References: <1190359905.3551.28.camel@magi.nadr>
	 <1190375946.4261.42.camel@localhost>  <1190379015.3551.57.camel@magi.nadr>
	 <1190381841.4231.10.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "auke-jan.h.kok@intel.com" <auke-jan.h.kok@intel.com>,
	netdev mailing list <netdev@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: Emil Micek <emil.micek@tkrjasek.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:39072 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757631AbXIUNqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 09:46:10 -0400
Received: by an-out-0708.google.com with SMTP id d31so130583and
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 06:46:09 -0700 (PDT)
In-Reply-To: <1190381841.4231.10.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-21-09 at 09:37 -0400, jamal wrote:
> On Fri, 2007-21-09 at 14:50 +0200, Emil Micek wrote:
> > On Fri, 2007-09-21 at 07:59 -0400, jamal wrote:
> 
> > > Which would make it a bug. AFAIK, the minimum VLAN tagged packet going
> > > out is 68 bytes.
> > Are you sure about this? 
> 
> This is what i have always seen. 

If the first email caused confusion - so will this ;->
I have never used e1000 for vlan tagging. My view is that if it emits
(instead of 68B) 64B packets with tags then it is buggy and needs to be
fixed. Hope that makes sense.


cheers,
jamal

