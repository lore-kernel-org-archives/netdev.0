From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp_reordering as 0 possible?
Date: Wed, 17 Mar 2010 13:38:15 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1003171333250.19416@melkinpaasi.cs.helsinki.fi>
References: <de0a9dcb1003150725h367d0548j35037441fdb2f5df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj ravi <mekaviraj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60390 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471Ab0CQLiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 07:38:17 -0400
In-Reply-To: <de0a9dcb1003150725h367d0548j35037441fdb2f5df@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Mar 2010, raj ravi wrote:

> what is the behaviour in TCP stack if I set tcp_reordering as 0.
> So , sender will  start retransmission without waiting for any duplicate ACK ?
> /proc/sys/net/ipv4/tcp_reordering   - Please clarify.
> The default value is 3 which means it waits until 3 duplicate ack's
> arrive and then start retransmission.
> 
> "The TCP sender should use the fast retransmit algorithm to detect and
> repair loss based on incoming duplicate ACKs. After the arrival of 3
> duplicate ACKs (4 identical ACKs without the arrival of any other
> intervening packet), TCP performs a retransmission of what appears to
> be the missing segment, without waiting for the retransmission timer
> to expire."

Depends on other things quite much but for a typical transfer you'd still 
need one duplicate ACK to trigger actual recovery. However, in general 
root is not (always) forbidden to set non-sensical values for sysctls.

-- 
 i.
