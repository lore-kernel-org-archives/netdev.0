From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: TI CPSW Ethernet Tx performance regression
Date: Wed, 15 Jan 2014 17:54:27 +0000
Message-ID: <1389808467.11912.9.camel@bwh-desktop.uk.level5networks.com>
References: <1389790129-5721-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40996 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbaAORyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 12:54:32 -0500
In-Reply-To: <1389790129-5721-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-15 at 18:18 +0530, Mugunthan V N wrote:
> Hi
> 
> I am seeing a performance regression with CPSW driver on AM335x EVM. AM335x EVM
> CPSW has 3.2 kernel support [1] and Mainline support from 3.7. When I am
> comparing the performance between 3.2 and 3.13-rc4. TCP receive performance of
> CPSW between 3.2 and 3.13-rc4 is same (~180Mbps) but TCP Transmit performance
> is poor comparing to 3.2 kernel. In 3.2 kernel is it *256Mbps* and in 3.13-rc4
> it is *70Mbps*
> 
> Iperf version is *iperf version 2.0.5 (08 Jul 2010) pthreads* on both PC and EVM
> 
> On UDP transmit also performance is down comparing to 3.2 kernel. In 3.2 it is
> 196Mbps for 200Mbps band width and in 3.13-rc4 it is 92Mbps
> 
> Can someone point me out where can I look for improving Tx performance. I also
> checked whether there is Tx descriptor over flow and there is none. I have
> tries 3.11 and some older kernel, all are giving ~75Mbps Transmit performance
> only.
> 
> [1] - http://arago-project.org/git/projects/?p=linux-am33x.git;a=summary

If you don't get any specific suggestions, you could try bisecting to
find out which specific commit(s) changed the performance.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
