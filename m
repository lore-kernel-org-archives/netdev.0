From: "Padiyar, Prasad (NSN - IN/Bangalore)" <prasad.padiyar@nsn.com>
Subject: RE: Information about SCTP patch
Date: Wed, 23 Jul 2014 11:55:20 +0000
Message-ID: <48119AB6DF184B48B2056EE384375EA91E965765@SGSIMBX006.nsn-intra.net>
References: <CAJ5TDg_0GjTWVin1Xr4sZwNhzMiT+bJPZwzfKB0xBdPMuK7T+g@mail.gmail.com>
 <20140627200644.GA9086@marquez.int.rhx>
 <CAJ5TDg_qOkpGe7Ouzn_wfbsODL4FoVLmq7EmQes6hEW-dnMLWg@mail.gmail.com>
 <20140722080304.GB7011@fante.int.rhx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kumar, Sumit 11. (NSN - IN/Bangalore)" <sumit.11.kumar@nsn.com>,
	kishan simha <ksimha123@gmail.com>
To: ext Michele Baldessari <michele@acksyn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:41427 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbaGWMSn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 08:18:43 -0400
In-Reply-To: <20140722080304.GB7011@fante.int.rhx>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michele,

Thanks for your time and reply.

We here have a requirement to implement a CLI to get these stats.
And one of the options we thought to use was /proc files to get these stats.

Going through the mail chain of this patch (http://www.spinics.net/lists/linux-sctp/msg01813.html) , I came across this.
" socket option is preferable as /proc doesn't scale very well as number of associations grows."


Here I am just curious to know how much "is the number of associations" referred to?


Thanks & Regards,
Prasad 

-----Original Message-----
From: ext Michele Baldessari [mailto:michele@acksyn.org] 
Sent: Tuesday, July 22, 2014 1:33 PM
To: kishan simha
Cc: linux-sctp@vger.kernel.org; netdev@vger.kernel.org; Padiyar, Prasad (NSN - IN/Bangalore); Kumar, Sumit 11. (NSN - IN/Bangalore)
Subject: Re: Information about SCTP patch

Hi Kishan,

On Mon, Jul 21, 2014 at 02:08:21PM +0530, kishan simha wrote:
> We are trying to integrate this patch to a little older kernel 2.6.34.13.

This is trivial as we've done so for RHEL 6.5 already.

> Additionally we are planning to give a proc file interface to display the stats.
> 
> I came across a review comment for your patch, where the proc solution
> was rejected.
> 
> Can you provide some information on why the solution was rejected ?

It was preferred to do it via an API extension, similar to how
Solaris does it. And, I believe, the /proc interface for these kind of
things is discouraged.

regards,
Michele
-- 
Michele Baldessari            <michele@acksyn.org>
C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
