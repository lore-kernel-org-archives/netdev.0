From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Fri, 5 Feb 2016 09:38:42 -0800
Message-ID: <20160205173841.GA23058@ast-mbp.thefacebook.com>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <20160203143133.1b70bcb5@redhat.com>
 <20160203133356.GA2219@nanopsycho.orion>
 <56B219FA.7080208@iogearbox.net>
 <56B35089.4000707@stressinduktion.org>
 <20160204132622.GB2198@nanopsycho.orion>
 <56B472F2.6080101@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34434 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755989AbcBERiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 12:38:46 -0500
Received: by mail-pa0-f49.google.com with SMTP id uo6so37981318pac.1
        for <netdev@vger.kernel.org>; Fri, 05 Feb 2016 09:38:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56B472F2.6080101@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 05, 2016 at 11:01:22AM +0100, Hannes Frederic Sowa wrote:
> 
> Okay. I see it more as changing mode of operation of hardware and thus has
> not really anything to do with networking. If you say you change ethernet to
> infiniband it has something to do with networking, sure. But I am fine with
> this, I just thought the code size could be reduced by adding this to sysfs
> quite a lot. I don't have a strong opinion on this.

there is already a way to change eth/ib via
echo 'eth' > /sys/bus/pci/drivers/mlx4_core/0000:02:00.0/mlx4_port1

sounds like this is another way to achieve the same?
Why not hide echo/cat in iproute2 instead of adding parallel netlink api?
Or this is for switches instead of nics?
Then why it's not adding to switchdev?
