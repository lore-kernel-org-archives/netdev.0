From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 0/5] Ease netns management for userland
Date: Wed, 12 Dec 2012 13:48:30 -0800
Message-ID: <87sj7beyc1.fsf@xmission.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
	<87fw3boyxn.fsf@xmission.com> <50C8EEF0.2010201@6wind.com>
	<87zk1jht7d.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, aatteka@nicira.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:43378 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755168Ab2LLVsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 16:48:38 -0500
In-Reply-To: <87zk1jht7d.fsf@xmission.com> (Eric W. Biederman's message of
	"Wed, 12 Dec 2012 13:11:02 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> It is very wrong to presume that without context you know the reason for
> the exsitence of any network namespace and that you should or even that
> you can manage it.  Think of running your multi-network namespace
> managing application in a container.

A good example of a network namespace you don't want to mess with are
the network namespaces created by vsftp and chrome for security purposes
to remove any possibility of creating new connections to the network.

Eric
