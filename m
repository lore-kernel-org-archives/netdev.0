From: Derek Fawcus <dfawcus@brocade.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Tue, 10 Feb 2015 10:43:33 +0000
Message-ID: <20150210104332.GA20679@dfawcus.brocade.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
 <54D3F8F9.2060500@cumulusnetworks.com>
 <54D424BD.2090402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: roopa <roopa@cumulusnetworks.com>, <netdev@vger.kernel.org>,
	<ebiederm@xmission.com>, Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	<hannes@stressinduktion.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:63732 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751185AbbBJKoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 05:44:03 -0500
Content-Disposition: inline
In-Reply-To: <54D424BD.2090402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 05, 2015 at 07:19:41pm -0700, David Ahern wrote:
> On 2/5/15 4:12 PM, roopa wrote:
> >Wondering if you have thought about some of the the below cases in your
> >approach to vrfs ?.
> >- Leaking routes from one vrf to another
> 
> Can you give me an example of what you mean by this?

I believe the following sort of thing is being referred to:

   http://packetlife.net/blog/2010/mar/29/inter-vrf-routing-vrf-lite/
   http://packetlife.net/blog/2013/sep/26/vrf-export-maps/
   https://rekrowten.wordpress.com/2012/09/24/route-leak-between-vrfs-with-import-maps-and-export-maps/

I google search for "bgp import OR export" brings a bunch of hits.

DF
