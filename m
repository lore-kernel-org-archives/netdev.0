From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net-next 3/9] mlx4: Implement port type setting via
 devlink interface
Date: Tue, 23 Feb 2016 09:31:39 -0800
Message-ID: <20160223093139.21303e16@samsung9>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
	<1456165924-14399-4-git-send-email-jiri@resnulli.us>
	<56CC41C8.10802@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34838 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692AbcBWRcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 12:32:07 -0500
Received: by mail-pf0-f178.google.com with SMTP id c10so119472941pfc.2
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 09:32:06 -0800 (PST)
In-Reply-To: <56CC41C8.10802@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Feb 2016 12:26:00 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> Hi Jiri,
> 
> On 22.02.2016 19:31, Jiri Pirko wrote:
> > From: Jiri Pirko <jiri@mellanox.com>
> >
> > So far, there has been an mlx4-specific sysfs file allowing user to
> > change port type to either Ethernet of InfiniBand. This is very
> > inconvenient.
> 
> Again, I want to express my concerns regarding all of this until this 
> will be integrated into udev/systemd for stable device names. While one 
> can build wrapper code around devlink to have stable devlink ports, I 
> don't see a reason to include kernel code which actually has more 
> problems than the sysfs approach. This harms admins to use those devices 
> and will additionally require user space to write boiler plate code.
> 
> Thanks,
> Hannes
> 

I appreciate that you need to have a lighterweight model for
network devices. But have to agree with Hannes.

This code breaks the model expected by applications like Quagga, SNMP
and lots of other legacy code. Is this really going to work with the
legacy Linux model.
