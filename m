From: James Chapman <jchapman@katalix.com>
Subject: Re: Wrong usage of hash in L2TP leading to NULL ptr derefs
Date: Mon, 28 May 2012 17:19:37 +0100
Message-ID: <4FC3A599.1040909@katalix.com>
References: <1338221539.4284.25.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:34046 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753855Ab2E1QTm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2012 12:19:42 -0400
In-Reply-To: <1338221539.4284.25.camel@lappy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/05/12 17:12, Sasha Levin wrote:
> Hi all,
> 
> Looking at net/l2tp/l2tp_ip{6}.c, l2tp uses UDP for communications, but
> uses inet_hash and inet_unhash for hashing - which appears to be wrong
> (and causes NULL ptr derefs during runtime).

L2TPv3 also supports IP encapsulation, which is L2TP directly in IP, no
UDP. That's what the l2tp_ip[6] code implements.

Can you post an oops with steps for how to reproduce it?


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
