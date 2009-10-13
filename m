From: Brian Haley <brian.haley@hp.com>
Subject: Re: Ping Is Broken
Date: Tue, 13 Oct 2009 09:48:37 -0400
Message-ID: <4AD48535.4000708@hp.com>
References: <7e84ed60910090316ne9224fat81d9c79c58fc713b@mail.gmail.com> <7e84ed60910090934y2a0d422cr158aa8d15e452f97@mail.gmail.com> <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com> <4AD39342.7090209@hp.com> <4AD3A388.7020709@gmail.com> <4AD3BC12.6020409@hp.com> <20091013051019.GA6159@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rob.Townley@gmail.com, netdev@vger.kernel.org,
	Omaha Linux User Group <olug@olug.org>,
	CentOS mailing list <centos@centos.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:43587 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbZJMNtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 09:49:15 -0400
In-Reply-To: <20091013051019.GA6159@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> I've commented your: "In this case ping is doing an SO_BINDTODEVICE to eth0",
> so meant: SO_BINDTODEVICE is used *by ping* only to acquire a source address.

Yes, sorry, it was too late here to be reading code :(  Setting the oif in the cmsg
has the same basic effect since it's going to influence the route lookup.

-Brian
