From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 1/2] ipmr: delete redundant variable
Date: Fri, 25 Jul 2008 19:36:42 +0200
Message-ID: <200807251936.42504.netdev@axxeo.de>
References: <48868D54.6050701@cn.fujitsu.com> <200807231405.39515.netdev@axxeo.de> <48883131.9070805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:35547 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423AbYGYRgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2008 13:36:55 -0400
In-Reply-To: <48883131.9070805@cn.fujitsu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wang Chen,

Wang Chen schrieb:
> Ingo Oeser said the following on 2008-7-23 20:05:
> > But please check the generated assembly yourself on a CISC and RISC
> > machine to get an idea of the effects. It will be a nice learning 
> > experience I enjoyed myself already.
> > 
> 
> I did the experiment.
[..]
> In loop area, they are both ptr+sizeof(struct).
> 
> Now, we can get a conclusion that current compiler can do optimize the index accessing.
> :)
> 
> Ingo, if you have any different opinion, it will be appreciated that you can share. :)

Great! Compilers improved a lot here :-)

Many thanks for doing this experiment. 

Now you and others can anyone who is is questioning
this fact to your experiment and take it as a reference for similiar changes.

That is a great help for the community, I think!


Best Regards

Ingo Oeser
