From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP being hoodwinked into spurious retransmissions by lack of
 timestamps?
Date: Fri, 21 Mar 2014 14:53:20 -0700
Message-ID: <532CB4D0.50403@hp.com>
References: <53151E55.9000503@hp.com> <CABrhC0=hHpZSdE5-dLqysuFn_d_VK7r1jKb0kGZF9hn1+UHjDw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:15539 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbaCUVxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 17:53:22 -0400
In-Reply-To: <CABrhC0=hHpZSdE5-dLqysuFn_d_VK7r1jKb0kGZF9hn1+UHjDw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/2014 07:22 PM, John Heffner wrote:
> Running with such a large window scale and no timestamps (PAWS
> protection) is generally not a great idea, but I don't think is part
> of the issue here.
>
> If you look where things really go wrong, the receiver is sending
> anomalous SACK blocks that will trigger the SACK renege handling path.
>   Reneging triggers go-back-n behavior, so we see the spurious
> retransmits from there on.

What triggers go-back-n when SACK is not in use?  I ask because at least 
once I have seen the same sort of thing without SACK enabled on the 
connection.  The total quantity of retransmissions is roughly the same, 
but spread-out - looks like cwnd shrinks considerably and re-grows in 
the no-SACK case.  Not sure I still have that trace though :(

rick jones
