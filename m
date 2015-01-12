From: Martin Lau <kafai@fb.com>
Subject: Re: [PATCH RFC net-next] ip_tunnel: create percpu gro_cell
Date: Mon, 12 Jan 2015 10:33:16 -0800
Message-ID: <20150112183316.GG3842288@devbig242.prn2.facebook.com>
References: <1420828933-844290-1-git-send-email-kafai@fb.com>
 <1420844264.5947.81.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150109231703.GF3842288@devbig242.prn2.facebook.com>
 <1420851759.5947.83.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:20197 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755446AbbALSdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 13:33:20 -0500
Content-Disposition: inline
In-Reply-To: <1420851759.5947.83.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 05:02:39PM -0800, Eric Dumazet wrote:
> On Fri, 2015-01-09 at 15:17 -0800, Martin Lau wrote:
> > Is the spin_lock() still needed?
> 
> Think about cpu hotplug, we can have interesting things here.
> 
> Basically no cost at all once mem is percpu.
Thanks, will post a v2.

--Martin
