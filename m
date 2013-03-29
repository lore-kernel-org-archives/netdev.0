From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] atl1e: drop pci-msi support because of packet corruption
Date: Fri, 29 Mar 2013 06:24:36 +0100
Message-ID: <20130329052436.GA29550@order.stressinduktion.org>
References: <20130329041050.GA29040@order.stressinduktion.org> <157393863283F442885425D2C45428564F2022D0@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rebelyouth.hacklab@gmail.com" <rebelyouth.hacklab@gmail.com>,
	"christian.suenkenberg@student.kit.edu"
	<christian.suenkenberg@student.kit.edu>,
	"sven@svenhartge.de" <sven@svenhartge.de>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37857 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752724Ab3C2FYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 01:24:38 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C45428564F2022D0@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 29, 2013 at 05:03:43AM +0000, Huang, Xiong wrote:
> you can try to enable rx-checksum offload if DMA issue disappear, as windows driver enable this feature.

We tested each change separately. So we had rx-checksum offload enabled
the whole time while testing this patch and it had not caused any
problems.

Greetings,

  Hannes
