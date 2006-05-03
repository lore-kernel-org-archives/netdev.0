From: "Chris Leech" <christopher.leech@intel.com>
Subject: Re: Question on e1000 patch, rx-copy-break related.
Date: Wed, 3 May 2006 11:21:47 -0700
Message-ID: <41b516cb0605031121y1c5208ebh1844f8a23a2363be@mail.gmail.com>
References: <4457B96A.4030808@candelatech.com>
	 <4807377b0605031022s3b5bfad2x757fbd470884c6fd@mail.gmail.com>
	 <4458F2A2.60605@candelatech.com>
Reply-To: chris.leech@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>,
	NetDev <netdev@vger.kernel.org>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:42415 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751351AbWECSWB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 14:22:01 -0400
Received: by py-out-1112.google.com with SMTP id x31so296603pye
        for <netdev@vger.kernel.org>; Wed, 03 May 2006 11:22:00 -0700 (PDT)
To: "Ben Greear" <greearb@candelatech.com>
In-Reply-To: <4458F2A2.60605@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/3/06, Ben Greear <greearb@candelatech.com> wrote:
> So, as of 2.6.16.13, is the hardware stripping (SERC) enabled?  Could
> you also let me know where this bit is defined in case I want to twiddle
> it myself (a quick grep for SERC in 2.6.16.13 yields nothing.)

You missed a C, it's SECRC (Strip Ethernet CRC) in the RCTL register
or E1000_RCTL_SECRC.

- Chris
